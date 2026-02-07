from flask import Flask, jsonify
import requests
from bs4 import BeautifulSoup
import re
from urllib.parse import quote

app = Flask(__name__)

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Referer': 'https://www.mct.gov.cn/'
}


def fetch_mct_news(city):
    search_city = city.replace('市', '')
    news_results = []

    encoded_city = quote(search_city)
    search_url = f"https://www.mct.gov.cn/was5/web/search?channelid=279730&searchword={encoded_city}"

    try:
        response = requests.get(search_url, headers=HEADERS, timeout=10)
        response.encoding = 'utf-8'  # 显式设置编码

        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')

            items = soup.find_all('li')

            for item in items:
                title_node = item.find('a')
                if title_node:
                    title = title_node.get_text().strip()
                    if search_city in title and len(title) > 8:
                        clean_t = re.sub(r'<[^>]+>', '', title)
                        if clean_t not in news_results:
                            news_results.append(clean_t)

                if len(news_results) >= 6:
                    break
    except Exception as e:
        print(f"爬取文旅部异常: {e}")

    return news_results


@app.route('/')
def welcome():
    return "寻域文旅大数据中心已启动！"

@app.route('/get_news/<city>')
def news_api(city):
    search_city = city.replace('市', '').replace('定位中...', '').strip()

    if not search_city:
        return jsonify({"code": 404, "news": []})

    print(f"--- 正在搜寻文旅部关于【{search_city}】的最新动态 ---")

    news = fetch_mct_news(search_city)

    return jsonify({
        "code": 200,
        "city": city,
        "news": news[:10]
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)