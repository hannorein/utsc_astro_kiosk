from flask import Flask, render_template

class FlaskApp(Flask):
    def __init__(self, *args, **kwargs):
        super(FlaskApp, self).__init__(*args, **kwargs)

app = FlaskApp(__name__)

@app.route('/')
@app.route('/kiosk/')
def page_kiosk():
    return render_template("kiosk.html")

if __name__ == '__main__':
    app.run(debug=True,threaded=True)
