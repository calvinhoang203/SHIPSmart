# SHIPSmart

## Inspiration

Have you ever walked out of a doctor’s appointment, already exhausted, only to be hit with a surprise bill? The expectation is endless phone calls, paperwork, and fighting with insurance companies just to understand what you owe. But what if it didn’t have to be that way? SHIPSmart is here to help UC students enrolled in SHIP take control of their healthcare costs. Our app estimates medical, dental, and vision costs upfront, ensuring the lowest possible price, and if our estimate is lower than what you were charged, we’ll fight for rebates and handle the follow-up claims. No more surprise bills, no more endless phone calls—just peace of mind knowing your insurance is working for you.

## What it does

SHIPSmart is a smart assistant for UC SHIP students, offering real-time cost estimates for medical, dental, and vision services. Using a secure login system and a locally hosted database, SHIPSmart tracks user details, past visits, and insurance data, updating this info with each chat. When a user interacts with SHIPSmart, the AI gathers information about their symptoms, priorities, and insurance status. Based on this data, it searches our SQL database for the best available providers and streamlines the booking process, including extracting details from insurance cards to auto-fill forms. SHIPSmart uses UC SHIP data to provide accurate medical cost estimates. By training an AI model on policy documents and using regression analysis on historical data, we guarantee precise estimates. Any discrepancies in pricing are flagged and managed — the AI will work with insurers and providers using Cerebras AI to track down the reason for the difference, ensuring users are either refunded or the issue is explained. Additionally, SHIPSmart updates policy changes and healthcare charges in real-time, automatically analyzing data to identify trends and price fluctuations for specific procedures.

## How we built it

We designed the app's interface using Figma to create an intuitive, user-friendly experience. The frontend was implemented with SwiftUI, ensuring smooth performance and a native feel on iOS devices. To power the user-facing side, we utilized the OpenAI/Gemini framework to build a complex AI agent that interacts with users, gathers necessary medical and insurance details, and provides real-time estimates. For backend functionalities, we integrated Cerebras AI to handle communications with insurers and providers, ensuring discrepancies in pricing are addressed. The AI also automates the filling of online intake forms by extracting relevant information from our database when possible.

## Challenges we ran into

This was our first time building a mobile app using SwiftUI, so it took us a while to get comfortable with the platform. We also faced difficulties with calling APIs and integrating the Firebase framework in SwiftUI. On the design side, creating a layout for a chatbot was challenging, and our designer struggled to find suitable ideas and resources. Additionally, we went through several design and idea changes to better fit the app’s vision, which took significant time and effort. Despite these challenges, we were able to complete the demo of the app and are excited to continue building it in the future.

## Accomplishments that we're proud of

None of us had prior experience with SwiftUI or working with AI technologies, but we successfully integrated the Cerebras API and got it running within our app. We made the most of the resources offered at HackDavis, including workshops and mentor support. We're especially proud of our perseverance—staying positive, working through the night, and debugging together. It’s easy to give up when things get hard, but we pushed through and stayed on track.

## What we learned

Through this experience, we gained valuable skills in leadership, teamwork, and collaboration. We shared ideas openly and treated each other with respect throughout the process. Technically, we learned a new programming language, how to make API calls, and got hands-on experience with AI and machine learning data. This project helped us grow both as developers and as a team.

## What's next for SHIPsmart

Expanding Coverage: We plan to broaden our reach to include all California residents, providing everyone with easy access to accurate cost estimates and insurance benefits. Multi-Insurance Support: We'll add functionality to handle users with multiple insurance policies, ensuring that estimates are optimized across all available coverage. Health Watchdog: We aim to introduce a passive health listener, which will monitor users' health activities and proactively recommend preventive care and services that are fully covered by their insurance, helping users get the most out of their benefits.
