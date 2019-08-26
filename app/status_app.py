# Application file
from flask import Flask, request, render_template
import requests
from requests.exceptions import ConnectionError, MissingSchema
import time
import redis

app = Flask(__name__)
url_dict = {}


r = redis.Redis(host='localhost',port=6379,password='baba1612', charset='utf-8', decode_responses=True)
print(r.keys())

def requesturl(processed_url):
    #url_dict[processed_url] = {}
    urlcheck = requests.get(processed_url)
    code = urlcheck.status_code
    epoch = int(time.time())
    timestamp = time.ctime(epoch)
    url_for_redis = processed_url.replace(".", "#")
    r.hmset(url_for_redis, {"code":code, "time": timestamp, "epoch":epoch})

    #url _dict[processed_url] = [int(time.time()), code]
    if code == 200:
        #print('This is requesturl code 200 block')
        #url_dict[processed_url]['availability']='The site is available'
        r.hmset(url_for_redis, {"message":"The site is available as per last timestamp"})
        return render_template('webpage.html', url = processed_url,  status=r.hget(url_for_redis, "code"), availability = r.hget(url_for_redis, "message"), \
            timestamp = r.hget(url_for_redis, "time"), cache = r.hgetall(url_for_redis))
    else:
        r.hmset(url_for_redis, {"message":"The site returned a non-200 code"})
        return render_template('webpage.html', url = processed_url, status=r.hget(url_for_redis, "code"),
                               availability = r.hget(url_for_redis, "message"), timestamp = r.hget(url_for_redis, "time"), cache = r.hgetall(url_for_redis))
    
@app.route('/') #If the user comes on /path, it gets redirected to webpage.htm saved under templates directory
def webpage():
    return render_template('webpage.html')# render_template will render and display the specified html page

@app.route('/', methods=['POST'])
def web_url():
    url = request.form['url']
    processed_url = url.lower()
    url_for_redis = processed_url.replace(".","#")
    try:
        if r.hexists(url_for_redis, "code"):
            if int(time.time()) - int(r.hget(url_for_redis, "epoch")) > 600:
                return requesturl(processed_url)
            else:
                return render_template('webpage.html', url = processed_url, status=r.hget(url_for_redis, "code"), availability = r.hget(url_for_redis, "message"), \
                    timestamp = r.hget(url_for_redis, "time"), cache = r.hgetall(url_for_redis))
        else:
            return requesturl(processed_url)
    except ConnectionError:
        return render_template('webpage.html', url = processed_url, status = 'The website does not exist')
    except MissingSchema:
        return render_template('webpage.html', url = processed_url, status = 'The URL format is incorrect. Please try again!')

if __name__=='__main__':
    app.run(host='0.0.0.0')


