import os
import brevo_python
from dotenv import load_dotenv

load_dotenv() 

BREVO_API_KEY = os.getenv("BREVO_API_KEY")
FROM_EMAIL = os.getenv("FROM_EMAIL", "LinkUp OTP")

configuration = brevo_python.Configuration()
configuration.api_key['api-key'] = BREVO_API_KEY
client = brevo_python.TransactionalEmailsApi(brevo_python.ApiClient(configuration))