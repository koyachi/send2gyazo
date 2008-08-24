import wsgiref.handlers
import time

from google.appengine.ext import webapp
from google.appengine.api import urlfetch

class MainPage(webapp.RequestHandler):
    def get(self):
        self.response.out.write("send2gyazo")

class Uploader(webapp.RequestHandler):
    def post(self):
        boundary = '----BOUNDARYBOUNDARY----'
        imagedata = self.request.body
        id = time.strftime("%Y%m%d%H%M%S")
        formatter = """--%(boundary)s\r
content-disposition: form-data; name="id"\r
\r
%(id)s\r
--%(boundary)s\r
content-disposition: form-data; name="imagedata"\r
\r
%(imagedata)s\r
\r
--%(boundary)s--\r
"""
        data = formatter % {'imagedata': imagedata,
                            'id': id,
                            'boundary': boundary}
        self.response.headers['Content-Type'] = 'text/plain'
        content_type = """multipart/form-data; boundary=%(boundary)s""" % {'boundary': boundary}
        result = urlfetch.fetch('http://gyazo.com/upload.cgi',
                                payload=data,
                                method=urlfetch.POST,
                                headers={'Content-type': content_type})
        if result.status_code == 200:
            self.response.out.write(result.content)
        else:
            self.response.out.write('ng')

class CyazoPage(webapp.RequestHandler):
    def get(self):
        self.redirect('/cyazo/')

def main():
    application = webapp.WSGIApplication([('/', MainPage),
                                          ('/upload', Uploader),
                                          ('/cyazo', CyazoPage)
                                          ],
                                         debug=True)
    wsgiref.handlers.CGIHandler().run(application)

if __name__ == "__main__":
    main()
