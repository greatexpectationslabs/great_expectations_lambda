import os
import sys
from chalice import Chalice
import boto3

app = Chalice(app_name='api')

BUCKET_NAME = f"{os.getenv('BUCKET_NAME')}"
s3 = boto3.resource('s3')
bucket = s3.Bucket(BUCKET_NAME)

@app.route('/')
def index():
    execute_idempotent_side_load()

    import great_expectations

    return {'great_expectations': 'is loaded!'}

def execute_idempotent_side_load():
    if not os.path.exists('/tmp/ge_deps.zip'):
        # get deps zip from s3
        bucket.download_file('ge_deps.zip', '/tmp/ge_deps.zip')

        # unzip deps
        import zipfile
        with zipfile.ZipFile('/tmp/ge_deps.zip', 'r') as zip_ref:
            zip_ref.extractall('/tmp')

        # add to module path
        sys.path.insert(0, '/tmp/deps')
        print('deps loaded to tmp')


# The view function above will return {"hello": "world"}
# whenever you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.current_request.json_body
#     # We'll echo the json body back to the user in a 'user' key.
#     return {'user': user_as_json}
#
# See the README documentation for more examples.
#
