from flask import Flask, jsonify
import requests
import re

app = Flask(__name__)

TIAN_APIKEY = "your_api_key"


@app.route('/')
def welcome():
    return "寻域大数据后端运行成功！"


def clean_title(title):
    title = re.sub(r'<[^>]+>', '', title)

    title = re.sub(r'[-_].*百科.*$', '', title)
    title = re.sub(r'[-_].*百度.*$', '', title)

    redundant_prefixes = ['武汉市', '上海市', '北京市', '天津市', '成都市', '重庆市']
    for p in redundant_prefixes:
        if title.startswith(p):
            title = title.replace(p, '', 1)

    return title.strip()

def get_combined_news(city):
    search_city = city.replace('市', '')
    combined_results = []

    url_travel = "https://apis.tianapi.com/travel/index"
    url_area = "https://apis.tianapi.com/areanews/index"

    # 1. 地区新闻接口
    try:
        res_area = requests.get(url_area, params={"key": TIAN_APIKEY, "areaname": search_city}, timeout=5).json()
        if res_area.get("code") == 200:
            for item in res_area.get("result", {}).get("list", []):
                title = item.get("title", "")
                if search_city in title:
                    combined_results.append(title)
    except:
        pass

    # 2. 旅游新闻接口
    try:
        res_travel = requests.get(url_travel, params={"key": TIAN_APIKEY, "word": search_city}, timeout=5).json()
        if res_travel.get("code") == 200:
            for item in res_travel.get("result", {}).get("newslist", []):
                title = item.get("title", "")
                if search_city in title and title not in combined_results:
                    combined_results.append(title)
    except:
        pass

    final_news = []
    for t in combined_results:
        clean_t = re.sub(r'<[^>]+>', '', t)
        if len(clean_t) > 10:
            final_news.append(clean_t)
    return final_news


@app.route('/get_news/<city>')
def news_api(city):
    search_city = city.replace('市', '').replace('定位中...', '')

    if not search_city:
        return jsonify({"code": 404, "news": []})

    print(f"--- 正在多接口检索【{search_city}】本地及文旅资讯 ---")
    news = get_combined_news(search_city)

    if not news:
        return jsonify({"code": 404, "news": []})

    return jsonify({
        "code": 200,
        "city": city,
        "news": news[:10]
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)