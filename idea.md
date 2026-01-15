Prompt:
did you hear about the Finger Chooser mobile app? it is a trend in the last few months. friends, family, or a group of people put their fingers on the screen, and the app gonna pick one of those fingers randomly.
I want to create a similar app, but with more features. I want to add dare packs, also those dare packs will be customized to the type of players, are they friends? family? couple? etc. also the place, are they in the college? public? home? etc.. genders of the players, all boys, all girls, mixed, etc.
The number of players may be needed for the customization.
So, you as an expert and as my partner in this project, I want you to draft a plan for developing this project for a mobile App (both IOS and Android, but initially it will be published on Android only, until we succeed, then it will be published on the IOS). The goal is to earn money from the app, so you must think of monetizing this app, by ads and subscriptions, or buying packs of our dares. Also, I want it to be a multilingual, starting by English and Arabic language (initially the focus gonna be more on the English)
I am a single developer, and I am a vibe coder, which means that I use AI LLM models to write prompts, and convert those prompts into codes, and I follow the instructions of the LLM to assemble the code and do the development steps, at the end it will be a complete APP, or in worst case it will be a working MVP that bring me money.
I am using Windows 11, and VS code, Flutter is a good idea, and Firebase from Google.
now, let's think about the app itself, the core functions, monetization, the dares categories, the UI/UX, and the line of the app. i don't know what is the correct phrase must be used by I chose line of the app. here is an example of what I mean by line of the app:

as for the functionally of choosing the the finger, I don't want it to be like a button "Select One", it must be a counter of e.g. 5 seconds since last one put his finger, and all fingers must be holding until the counter of 5 seconds finishes. got it?
also, let's say that the user chose the fingerchooser playground and didn't select the dares (assuming they have their own dares), in this case, no need for the option of Repeat/END
on other hand, I am thinking of making an option if the Game Setup, when user choose one of our dares, we give like a combox or two options like "First loose" and "Last loose", which mean if the user selected the option "first is the looser", the game will be finished and dare will be showed up on the screen. and vice versa for the option "the last is the looser" (here, we are assuming that we know the number of the players (maybe added by the user in the game setup))

in short, line of the app means what user gonna do from the moment of opening the app until closing it; he will open the app, seeing e.g. Welcome Page, an option for language and game setup, game setup like directly to finger chooser playground? or customized (by adding the genders, indoor outdoor, home etc.,)

-----
Response:
========== 1. PRODUCT VISION ==========  
A light-hearted party game that decides “who’s next” with a multi-finger selector, then immediately shows a dare that perfectly fits the people, place and mood.  
Business goal: a highly viral, low–friction app that (1) earns through ads, in-app packs and an optional subscription, and (2) can be updated remotely with fresh dares and languages.  

========== 2. CORE FEATURES ==========  
A. Finger-Chooser Engine  
 • Multi-touch detection (2–10 fingers)  
 • 5-second countdown that starts after the last finger lands  
 • Auto-cancel if any finger lifts early (“false start”)  
 • Random winner (or “last finger left” option)  
 • Visual burst animation + haptic feedback on the chosen finger  

B. Dare System  
 • Pre-written dares stored as structured JSON:  
   {
     id, text_en, text_ar, groupType:[friends,family,couple…],  
     place:[home,college,public], gender:[boys,girls,mixed],  
     intensity:[mild,spicy,wild], minPlayers,maxPlayers
   }  
 • Client-side filtering that matches current game setup  
 • Pack types  
   – Free Core Pack (always available)  
   – Themed Premium Packs (IAP)  
   – Limited-time Packs (unlocked by Rewarded Ad)  
   – “All Access Pro” (subscription, ads removed)  

C. Game Modes  
 1. Quick Play → Finger chooser only (no dare, no repeat/ end menu)  
 2. Custom Play (wizard)  
    Step 1 ‑- Players (# & genders)  
    Step 2 ‑- Relationship (friends / family / couple / kids / coworkers)  
    Step 3 ‑- Location (home / campus / public / party)  
    Step 4 ‑- Lose Rule (first/last finger)  
    Step 5 ‑- Choose Dare Pack(s)  

D. Social / Viral Hooks  
 • Share result card (winner + dare) to WhatsApp / IG Stories  
 • “Invite a friend” referral link (Firebase Dynamic Links)  

========== 3. MONETISATION PLAN ==========  
1. AdMob  
   • Home & set-up screens: small banner  
   • After every 3 games: interstitial  
   • Unlock a premium pack for 24 h = rewarded video  
2. In-App Purchases  
   • Single premium pack ~ US$1–3 (consumable = permanent unlock)  
3. Subscription “Pro Pass” (auto-renew)  
   • All packs + ad-free + early access to new languages  
   • Intro price (1 week free)  
4. Storefront screen with bundle promotions & remote-config pricing  

========== 4. TECH STACK ==========  
• Flutter 3.x  |  VS Code on Win 11 | Dart  
• Firebase suite  
  – Firestore (dare content, pack metadata)  
  – Remote Config (A/B, pricing, feature flags)  
  – Auth (anonymous → upgrade)  
  – Cloud Functions (content moderation, push)  
  – Analytics + Crashlytics  
• RevenueCat (optional) for IAP / subscriptions wrapper  
• i18n: flutter_intl (arb files, RTL support)  
• State: Riverpod (lightweight + testable)  

========== 5. HIGH-LEVEL ARCHITECTURE ==========  
 UI Layer  ──►  State (Riverpod)  ──►  Service Layer  
                                   │          │  
                                   │          ├── FingerEngine  
                                   │          ├── DareFilter  
                                   │          ├── BillingService (IAP/Ads)  
                                   │          └── RemoteConfigService  
 Data Sources: Firestore ↔ Cache (Hive) | Local JSON fallback  

========== 6. USER FLOW (“LINE OF THE APP”) ==========  
1. Splash (2 s) → loads Remote Config & localization  
2. On first launch: Language chooser (English, عربي)  
3. Home  
   • Quick Play button  
   • Custom Play button  
   • “Store / Packs”  
   • “Remove Ads” banner (if ads active)  
4. Wizard (Custom Play) → Game Screen  
5. Finger Placement Screen  
   a) Title: “Everybody place a finger!”  
   b) Live counter (# fingers)  
   c) When last finger touches → 5-second radial countdown  
   d) Winner animation → Dare card  
6. Result Screen  
   • Show Dare + buttons: “Repeat” / “Home”  
   • Share icon  
7. End of session → Prompt rating after N sessions  

========== 7. DARE PACK ROADMAP ==========  
• Core (free) – 75 safe dares suitable for mixed ages  
• Party Starter – mild/spicy college dares  
• Couples – flirty, romantic  
• Family Night – kid-safe, indoors  
• Truth or Dare combo pack  
• Seasonal specials (Halloween, Ramadan, Xmas…)  

========== 8. MULTILINGUAL STRATEGY ==========  
Step 1 – Code prepared for RTL (Directionality widget), separate font for Arabic  
Step 2 – Keep all copy in .arb files → Google Sheet for translators  
Step 3 – Phase 1 ship with EN strings, 25 % of dares translated to AR (fallback to EN)  
Step 4 – Use Remote Config flag to roll out full-AR when ready  

========== 9. DEV ROADMAP (Solo Dev, 12-Week Target) ==========  
Week 1 Product spec, wireframes (Figma)  
Week 2-3 Project setup, localisation scaffolding, navigation shell  
Week 4 FingerEngine + basic animation, Quick Play MVP  
Week 5 Custom Play wizard UI  
Week 6 DareFilter logic; load dares from local JSON  
Week 7 Firestore integration, Remote Config, Hive cache  
Week 8 AdMob banners & interstitials, analytics events  
Week 9 IAP flow with a dummy premium pack, Polyglot test (AR)  
Week10 UX polish, haptics, share sheet, rating prompt  
Week11 Closed beta (Firebase testers), bug fixing, crash monitoring  
Week12 Launch on Google Play (Open testing → Prod)  

========== 10. AI-ASSISTED CODING WORKFLOW ==========  
• Prompt LLM for each component skeleton (“Write a Flutter widget that…”)  
• Ask for unit-test stubs, then adapt  
• Use “explain code” prompts to speed up debugging  
• Generate batch dare content & translations with LLM (human review for safety)  

========== 11. RISK & MITIGATION ==========  
• Content inappropriateness → moderation rules + report button  
• Multi-touch inconsistencies across devices → extensive physical testing + fallback “Tap to select” mode  
• Low ARPDAU → A/B ad frequency with Remote Config  
• Translation quality → community feedback loop, in-app “Wrong translation?” link  

========== 12. NEXT ACTIONS (THIS WEEK) ==========  
1. Create Figma wireframes for the 7 key screens.  
2. Set up Flutter project with intl & Riverpod packages.  
3. Prototype FingerEngine using GestureDetector + Listener and verify 5-second logic on two Android devices.  
4. Draft 100 English dares in Google Sheet with the metadata columns; run LLM to propose Arabic versions.  
5. Register AdMob & Firebase projects.  

When those four tasks are done, you’ll have a runnable skeleton and clear content pipeline—then we can iterate on polish and monetisation.