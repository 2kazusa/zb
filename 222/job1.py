from bottle import route,template,run,Bottle,static_file
import pymysql

# （1）分析并统计招聘数量最多的前十名热门职位,分别使用折线图表达（2）分析并统计招聘数量"大数据"相关职位招聘数量,分别使用柱状图表达。（3）统计出全国某些城市指定招聘岗位平均工资，通过南丁格尔玫瑰图进行呈现。
# 1.以招聘大数据相关岗位数量为依据绘制散点热度地图。同时在网页后台输出相关数据打印语句；2.请统计 2018 年，2019 年各月份大数据相关职位的招聘数量，以左右分布的（左侧 2018 年度，右侧 2019 年度）饼图进行表达

job_1 = Bottle()
@job_1.route("/")
def index():
    conn = pymysql.connect(host="192.168.28.170", port=3306, user="root", passwd='???????', db="visiondata_2")
    myCursor = conn.cursor()
    sql_str = "select * from hot_work order by job_number desc limit 10"
    myCursor.execute(sql_str)
    rs = myCursor.fetchall()
    myCursor.close()
    job = []
    num = []
    for item in rs:
        job.append(item[0])
        num.append(item[1])
    return template("job.html", job=job, num=num)
@job_1.route("/job1")
def hot_job():
    conn = pymysql.connect(host="192.168.28.170", port=3306, user="root", passwd='????????', db="visiondata_2")
    myCursor = conn.cursor()
    sql_str = "select * from hot_work order by job_number desc limit 10"
    myCursor.execute(sql_str)
    rs = myCursor.fetchall()
    myCursor.close()
    job = []
    num = []
    for item in rs:
        job.append(item[0])
        num.append(item[1])
    return template("job.html",job=job,num=num)

@job_1.route("/job2")
def hot_job():
    conn = pymysql.connect(host="192.168.28.170", port=3306, user="root", passwd='????????', db="visiondata_2")
    myCursor = conn.cursor()
    sql_str="select * from hot_work where job_name like '%大数据%'"
    myCursor.execute(sql_str)
    rs = myCursor.fetchall()
    myCursor.close()
    job = []
    num = []
    for item in rs:
        job.append(item[0])
        num.append(item[1])
    return template("job2.html",job=job,num=num)

@job_1.route("/job3")
def hot_job():
    conn = pymysql.connect(host="192.168.28.170", port=3306, user="root", passwd='199826', db="visiondata_2")
    myCursor = conn.cursor()
    sql_str1 = "select * from avg_money_bigdata"
    sql_str2 = "select * from avg_money_city"
    myCursor.execute(sql_str1)
    bigdata = myCursor.fetchall()
    myCursor.execute(sql_str2)
    city = myCursor.fetchall()
    myCursor.close()
    list_1 = []
    list_2 = []
    for item in city:
        dic = {}
        dic['value'] = item[1]
        dic['name'] = item[0]
        list_1.append(dic)
    for item in bigdata:
        dic = {}
        dic['value'] = item[1]
        dic['name'] = item[0]
        list_2.append(dic)
    return template("job3.html",list_1=list_1,list_2=list_2)

@job_1.route("/static/<filepath:path>")
def static_files(filepath):
    return static_file(filepath,root='./static')

run(app=job_1)