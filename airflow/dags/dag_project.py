from airflow import DAG
from datetime import datetime
from airflow.decorators import task
from airflow.operators.bash import BashOperator
from airflow.providers.amazon.aws.operators.lambda_function import AwsLambdaInvokeFunctionOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.utils.trigger_rule import TriggerRule

default_args = {"owner": "airflow"}

with DAG(
    dag_id='dag_project',
    start_date=datetime(2022,12,19),
    schedule_interval='@daily',
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=['project']
) as dag:

    invoke_scraper_lambda_function = AwsLambdaInvokeFunctionOperator(
    task_id='scraper_lambda_function',
    function_name="data_scraping"
    )

    s3_raw_data_sensor = S3KeySensor(
        task_id='wait_for_raw_data',
        bucket_name="rawrealstatelima",
        bucket_key="rawdata/raw_real_state.csv",
        mode="poke",
        poke_interval=5,
        timeout=300
    )

    invoke_cleaner_lambda_function = AwsLambdaInvokeFunctionOperator(
    task_id='cleaner_lambda_function',
    function_name="data_cleaning"
    )

    s3_clean_data_sensor = S3KeySensor(
        task_id='wait_for_clean_data',
        bucket_name="cleanrealstatelima",
        bucket_key="accessdata/access_real_state.csv",
        mode="poke",
        poke_interval=5,
        timeout=300
    )

    invoke_uploader_lambda_function = AwsLambdaInvokeFunctionOperator(
    task_id='upload_lambda_function',
    function_name="data_redshift"
    )

    pipeline_success = BashOperator (
        task_id="Message_success",
        bash_command="echo PIPELINE COMPLETED!",
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    pipeline_failed = BashOperator (
        task_id="Message_failure",
        bash_command="echo PIPELINE FAILED!",
        trigger_rule=TriggerRule.ONE_FAILED
    )



    invoke_scraper_lambda_function >> s3_raw_data_sensor >> invoke_cleaner_lambda_function >> s3_clean_data_sensor >> invoke_uploader_lambda_function >> [pipeline_success, pipeline_failed]