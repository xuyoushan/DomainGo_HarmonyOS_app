/**
 * 严格按照用户文档定义的政务数据接口
 */
export interface DistrictDetail {
  name: string;          // 区县名
  belong: string;        // 行政隶属
  postCode: string;      // 邮编
  areaCode: string;      // 区号
  population: string;    // 常住人口
  subLocality?: string[]; // 可选：用于存放该区下辖的特定地名（用于搜索匹配）
}

/**
 * 严格基于用户提供的文字稿还原的数据库
 */
export const CITY_GOV_DATA: Record<string, DistrictDetail[]> = {
  "北京市": [
    { name: '东城区', belong: '北京市', postCode: '100010', areaCode: '010', population: '约70.3万' },
    { name: '西城区', belong: '北京市', postCode: '100032', areaCode: '010', population: '约110.6万' },
    { name: '朝阳区', belong: '北京市', postCode: '100020', areaCode: '010', population: '约345.2万' },
    { name: '丰台区', belong: '北京市', postCode: '100071', areaCode: '010', population: '约201.9万' },
    { name: '石景山区', belong: '北京市', postCode: '100043', areaCode: '010', population: '约56.8万' },
    { name: '海淀区', belong: '北京市', postCode: '100089', areaCode: '010', population: '约312.2万' },
    { name: '门头沟区', belong: '北京市', postCode: '102300', areaCode: '010', population: '约39.6万' },
    { name: '房山区', belong: '北京市', postCode: '102400', areaCode: '010', population: '约131.3万' },
    { name: '通州区', belong: '北京市', postCode: '101100', areaCode: '010', population: '约184.5万' },
    { name: '顺义区', belong: '北京市', postCode: '101300', areaCode: '010', population: '约132.4万' },
    { name: '昌平区', belong: '北京市', postCode: '102200', areaCode: '010', population: '约226.9万' },
    { name: '大兴区', belong: '北京市', postCode: '102600', areaCode: '010', population: '约199.3万' },
    { name: '怀柔区', belong: '北京市', postCode: '101400', areaCode: '010', population: '约44.1万' },
    { name: '平谷区', belong: '北京市', postCode: '101200', areaCode: '010', population: '约45.7万' },
    { name: '密云区', belong: '北京市', postCode: '101500', areaCode: '010', population: '约52.7万' },
    { name: '延庆区', belong: '北京市', postCode: '102100', areaCode: '010', population: '约34.6万' }
  ],
  "上海市": [
    { name: '黄浦区', belong: '上海市', postCode: '200001', areaCode: '021', population: '约50.34万' },
    { name: '徐汇区', belong: '上海市', postCode: '200030', areaCode: '021', population: '约111.3万' },
    { name: '长宁区', belong: '上海市', postCode: '200050', areaCode: '021', population: '约69.3万' },
    { name: '静安区', belong: '上海市', postCode: '200040', areaCode: '021', population: '约97.5万' },
    { name: '普陀区', belong: '上海市', postCode: '200333', areaCode: '021', population: '约123.9万' },
    { name: '虹口区', belong: '上海市', postCode: '200080', areaCode: '021', population: '约75.7万' },
    { name: '杨浦区', belong: '上海市', postCode: '200082', areaCode: '021', population: '约124.2万' },
    { name: '闵行区', belong: '上海市', postCode: '201100', areaCode: '021', population: '约265.3万' },
    { name: '宝山区', belong: '上海市', postCode: '201900', areaCode: '021', population: '约223.5万' },
    { name: '嘉定区', belong: '上海市', postCode: '201800', areaCode: '021', population: '约183.4万' },
    { name: '浦东新区', belong: '上海市', postCode: '200120', areaCode: '021', population: '约578.58万' },
    { name: '金山区', belong: '上海市', postCode: '201500', areaCode: '021', population: '约82.2万' },
    { name: '松江区', belong: '上海市', postCode: '201600', areaCode: '021', population: '约190.9万' },
    { name: '青浦区', belong: '上海市', postCode: '201700', areaCode: '021', population: '约127.1万' },
    { name: '奉贤区', belong: '上海市', postCode: '201400', areaCode: '021', population: '约114.0万' },
    { name: '崇明区', belong: '上海市', postCode: '202150', areaCode: '021', population: '约67.2万' }
  ],
  "天津市": [
    { name: '和平区', belong: '天津市', postCode: '300041', areaCode: '022', population: '约44万' },
    { name: '河东区', belong: '天津市', postCode: '300171', areaCode: '022', population: '约85万' },
    { name: '河西区', belong: '天津市', postCode: '300202', areaCode: '022', population: '约88万' },
    { name: '南开区', belong: '天津市', postCode: '300100', areaCode: '022', population: '约104万' },
    { name: '河北区', belong: '天津市', postCode: '300143', areaCode: '022', population: '约64万' },
    { name: '红桥区', belong: '天津市', postCode: '300131', areaCode: '022', population: '约53万' },
    { name: '东丽区', belong: '天津市', postCode: '300300', areaCode: '022', population: '约85万' },
    { name: '西青区', belong: '天津市', postCode: '300380', areaCode: '022', population: '约118万' },
    { name: '津南区', belong: '天津市', postCode: '300350', areaCode: '022', population: '约92万' },
    { name: '北辰区', belong: '天津市', postCode: '300400', areaCode: '022', population: '约91万' },
    { name: '武清区', belong: '天津市', postCode: '301700', areaCode: '022', population: '约110万' },
    { name: '宝坻区', belong: '天津市', postCode: '301800', areaCode: '022', population: '约72万' },
    { name: '滨海新区', belong: '天津市', postCode: '300450', areaCode: '022', population: '约206万' },
    { name: '宁河区', belong: '天津市', postCode: '301500', areaCode: '022', population: '约39万' },
    { name: '静海区', belong: '天津市', postCode: '301600', areaCode: '022', population: '约68万' },
    { name: '蓟州区', belong: '天津市', postCode: '301900', areaCode: '022', population: '约79万' }
  ],
  "重庆市": [
    { name: '渝中区', belong: '重庆市', postCode: '400010', areaCode: '023', population: '约58万' },
    { name: '大渡口区', belong: '重庆市', postCode: '400080', areaCode: '023', population: '约35万' },
    { name: '江北区', belong: '重庆市', postCode: '400020', areaCode: '023', population: '约92万' },
    { name: '沙坪坝区', belong: '重庆市', postCode: '400030', areaCode: '023', population: '约147万' },
    { name: '九龙坡区', belong: '重庆市', postCode: '400050', areaCode: '023', population: '约152万' },
    { name: '南岸区', belong: '重庆市', postCode: '400064', areaCode: '023', population: '约96万' },
    { name: '北碚区', belong: '重庆市', postCode: '400700', areaCode: '023', population: '约83万' },
    { name: '渝北区', belong: '重庆市', postCode: '401120', areaCode: '023', population: '约220万' },
    { name: '巴南区', belong: '重庆市', postCode: '401320', areaCode: '023', population: '约117万' },
    { name: '万州区', belong: '重庆市', postCode: '404000', areaCode: '023', population: '约156万' },
    { name: '涪陵区', belong: '重庆市', postCode: '408000', areaCode: '023', population: '约111万' },
    { name: '黔江区', belong: '重庆市', postCode: '409000', areaCode: '023', population: '约55万' },
    { name: '长寿区', belong: '重庆市', postCode: '401220', areaCode: '023', population: '约69万' },
    { name: '江津区', belong: '重庆市', postCode: '402260', areaCode: '023', population: '约135万' },
    { name: '合川区', belong: '重庆市', postCode: '401520', areaCode: '023', population: '约125万' },
    { name: '永川区', belong: '重庆市', postCode: '402160', areaCode: '023', population: '约114万' },
    { name: '南川区', belong: '重庆市', postCode: '408400', areaCode: '023', population: '约57万' },
    { name: '綦江区', belong: '重庆市', postCode: '401420', areaCode: '023', population: '约80万' },
    { name: '大足区', belong: '重庆市', postCode: '402360', areaCode: '023', population: '约84万' },
    { name: '璧山区', belong: '重庆市', postCode: '402760', areaCode: '023', population: '约76万' },
    { name: '铜梁区', belong: '重庆市', postCode: '402560', areaCode: '023', population: '约68万' },
    { name: '潼南区', belong: '重庆市', postCode: '402660', areaCode: '023', population: '约68万' },
    { name: '荣昌区', belong: '重庆市', postCode: '402460', areaCode: '023', population: '约70万' },
    { name: '开州区', belong: '重庆市', postCode: '405400', areaCode: '023', population: '约120万' },
    { name: '梁平区', belong: '重庆市', postCode: '405200', areaCode: '023', population: '约65万' },
    { name: '武隆区', belong: '重庆市', postCode: '408500', areaCode: '023', population: '约41万' },
    { name: '城口县', belong: '重庆市', postCode: '405900', areaCode: '023', population: '约19万' },
    { name: '丰都县', belong: '重庆市', postCode: '408200', areaCode: '023', population: '约55万' },
    { name: '垫江县', belong: '重庆市', postCode: '408300', areaCode: '023', population: '约65万' },
    { name: '忠县', belong: '重庆市', postCode: '404300', areaCode: '023', population: '约72万' },
    { name: '云阳县', belong: '重庆市', postCode: '404500', areaCode: '023', population: '约93万' },
    { name: '奉节县', belong: '重庆市', postCode: '404600', areaCode: '023', population: '约74万' },
    { name: '巫山县', belong: '重庆市', postCode: '404700', areaCode: '023', population: '约46万' },
    { name: '巫溪县', belong: '重庆市', postCode: '405800', areaCode: '023', population: '约38万' },
    { name: '石柱县', belong: '重庆市', postCode: '409100', areaCode: '023', population: '约38万' },
    { name: '秀山县', belong: '重庆市', postCode: '409900', areaCode: '023', population: '约53万' },
    { name: '酉阳县', belong: '重庆市', postCode: '409800', areaCode: '023', population: '约60万' },
    { name: '彭水县', belong: '重庆市', postCode: '409600', areaCode: '023', population: '约53万' }
  ],
  "武汉市": [
    { name: '江岸区', belong: '湖北省武汉市', postCode: '430014', areaCode: '027', population: '约96.5万' },
    { name: '江汉区', belong: '湖北省武汉市', postCode: '430022', areaCode: '027', population: '约64.7万' },
    { name: '硚口区', belong: '湖北省武汉市', postCode: '430033', areaCode: '027', population: '约85.5万' },
    { name: '汉阳区', belong: '湖北省武汉市', postCode: '430050', areaCode: '027', population: '约90.1万' },
    { name: '武昌区', belong: '湖北省武汉市', postCode: '430061', areaCode: '027', population: '约127.05万' },
    { name: '青山区', belong: '湖北省武汉市', postCode: '430080', areaCode: '027', population: '约46.3万' },
    { name: '洪山区', belong: '湖北省武汉市', postCode: '430070', areaCode: '027', population: '约175.3万' },
    { name: '东西湖区', belong: '湖北省武汉市', postCode: '430040', areaCode: '027', population: '约91.7万' },
    { name: '汉南区', belong: '湖北省武汉市', postCode: '430090', areaCode: '027', population: '约14.5万' },
    { name: '蔡甸区', belong: '湖北省武汉市', postCode: '430100', areaCode: '027', population: '约55.4万' },
    { name: '江夏区', belong: '湖北省武汉市', postCode: '430200', areaCode: '027', population: '约106.33万', subLocality: ['金口', '庙山', '纸坊', '乌龙泉', '藏龙岛'] },
    { name: '黄陂区', belong: '湖北省武汉市', postCode: '430300', areaCode: '027', population: '约115.1万' },
    { name: '新洲区', belong: '湖北省武汉市', postCode: '430400', areaCode: '027', population: '约86.0万' }
  ],
  "成都市": [
    { name: '武侯区', belong: '四川省成都市', postCode: '610041', areaCode: '028', population: '约134万' },
    { name: '锦江区', belong: '四川省成都市', postCode: '610011', areaCode: '028', population: '约62万' },
    { name: '青羊区', belong: '四川省成都市', postCode: '610031', areaCode: '028', population: '约72万' },
    { name: '金牛区', belong: '四川省成都市', postCode: '610036', areaCode: '028', population: '约77万' },
    { name: '成华区', belong: '四川省成都市', postCode: '610066', areaCode: '028', population: '约79万' },
    { name: '龙泉驿区', belong: '四川省成都市', postCode: '610100', areaCode: '028', population: '约74万' },
    { name: '青白江区', belong: '四川省成都市', postCode: '610300', areaCode: '028', population: '约42万' },
    { name: '新都区', belong: '四川省成都市', postCode: '610500', areaCode: '028', population: '约82万' },
    { name: '温江区', belong: '四川省成都市', postCode: '611100', areaCode: '028', population: '约51万' },
    { name: '双流区', belong: '四川省成都市', postCode: '610200', areaCode: '028', population: '约138万' },
    { name: '郫都区', belong: '四川省成都市', postCode: '611700', areaCode: '028', population: '约65万' },
    { name: '新津区', belong: '四川省成都市', postCode: '611400', areaCode: '028', population: '约32万' },
    { name: '都江堰市', belong: '四川省成都市', postCode: '611800', areaCode: '028', population: '约62万' },
    { name: '彭州市', belong: '四川省成都市', postCode: '611900', areaCode: '028', population: '约80万' },
    { name: '邛崃市', belong: '四川省成都市', postCode: '611500', areaCode: '028', population: '约65万' },
    { name: '崇州市', belong: '四川省成都市', postCode: '611200', areaCode: '028', population: '约66万' },
    { name: '简阳市', belong: '四川省成都市', postCode: '641400', areaCode: '028', population: '约150万' },
    { name: '金堂县', belong: '四川省成都市', postCode: '610400', areaCode: '028', population: '约90万' },
    { name: '大邑县', belong: '四川省成都市', postCode: '611300', areaCode: '028', population: '约51万' },
    { name: '蒲江县', belong: '四川省成都市', postCode: '611600', areaCode: '028', population: '约27万' }
  ]
};