import os
from openai import OpenAI
import requests
from dotenv import load_dotenv

load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
# Load system prompt
with open("system_prompt.txt", "r") as f:
    system_prompt = f.read()

# Get user context (replace with actual UID you're testing)
uid = "918859330"
student = requests.get(f"http://localhost:8000/students/{uid}").json()

# Initial conversation history
messages = [
    {"role": "system", "content": system_prompt},
    {"role": "user", "content": f"Student info: {student}"},
]

print("👩‍⚕️ SHIPSmart is ready. Ask your insurance cost question below.")
print("Type 'exit' to quit.\n")

while True:
    user_input = input("🧑 You: ")

    if user_input.lower() in {"exit", "quit"}:
        print("👋 Bye! Stay healthy.")
        break

    # Add user message to history
    messages.append({"role": "user", "content": user_input})

    # Send to OpenAI
    response = client.chat.completions.create(model="gpt-3.5-turbo",
    messages=messages,
    temperature=0.3)

    ai_message = response.choices[0].message.content
    messages.append({"role": "assistant", "content": ai_message})

    print("\n🤖 SHIPSmart:\n")
    print(ai_message)
    print("\n---")
