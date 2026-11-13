# Control Center for Omni SEs

A personal home base for running prospect trials (POCs). The page runs as a Claude artifact on claude.ai and pulls live data from your connected Slack, Gmail, Google Calendar, Fathom and Omni Analytics. Nothing is stored on a server: every load reads your accounts fresh, and preferences stay in your own browser.

## What it does

**Home page**

- **Your trials:** finds your active eval channels in Slack (channels you've posted in over the last 60 days that start with `omni-`, mention "eval", or were created by the eval-channel bot). Each card shows the trial day, the AE and the next meeting. You can filter the cards by name or by AE.
- **Next three days:** your upcoming meetings, with customer meetings highlighted and a "Prep me" brief for each one.
- **Where things stand:** quick stats and a "Brief me on today" summary.
- **Your follow-ups:** your open Fathom action items from the last 7 days.
- **Waiting on you:** Slack DMs and @mentions, plus inbox email where someone else wrote last, each with a link back to Slack or Gmail.
- **Prospect follow-up:** drafts a concise Slack follow-up from a Fathom link and/or topics, with links from the Omni docs.
- **Omni docs:** answers product questions from docs.omni.co, with sources.
- **Competitive intel:** copies a prompt to paste into a Claude chat where your compete skill is available.

**Trial pages** (click a trial card)

- **Ask about [prospect]:** a chat limited to that one trial. It can search that prospect's email threads, Slack links, calendar and Fathom calls.
- **Timeline:** trial start and end dates, with a dot for each meeting.
- **Where it stands:** an AI summary of the trial's health, risks and next steps.
- **Meetings:** newest first, with recording links.
- **Open items from calls:** Fathom action items.
- **Stakeholders:** prospect and Omni people involved in the trial.
- **Latest in #channel:** recent Slack messages, each linking to the message in Slack.
- **Email threads:** recent threads with the prospect, each linking to Gmail.

Every section can be expanded and collapsed, and there's an Expand/Collapse all button. Three themes are available: Omni, Midnight and New York City.

## Requirements

- A claude.ai account. The page only works as a published Claude artifact; opening `index.html` directly in a browser shows "Connectors aren't available".
- These connectors set up in claude.ai (Settings → Connectors): **Slack**, **Gmail**, **Google Calendar**, **Official Fathom** and **Omni Analytics**.

## Set it up for yourself

### 1. Edit the settings block

Open `index.html` and find the block marked **YOUR SETTINGS**, near the top of the main `<script>`:

| Setting | What to put | Where to find it |
|---|---|---|
| `name` | Your full name | As it appears in Fathom and Slack |
| `first` | Your first name | Used in greetings and AI prompts |
| `email` | Your work email | — |
| `role` | Your role, e.g. `Solutions Engineer` | Used in AI prompts |
| `slackUserId` | Your Slack member ID, e.g. `U0ABC12345` | In Slack, open your profile, then ⋮, then **Copy member ID** |
| `slackWorkspace` | The part before `.slack.com` in your Slack URL | `exploreomni` for Omni |
| `internalDomains` | Your company's email domains | Leave as-is for Omni |
| `evalChannelBot` | Name of the Slack app that creates trial channels | Leave as-is for Omni |
| `notTrialChannels` | Channels never to treat as trials | Add any internal `omni-…` channels you post in |

### 2. Publish it as an artifact

Start a new chat on claude.ai, attach your edited `index.html`, and send:

> Publish this HTML file as an artifact without changing it, with these capabilities:
>
> ```json
> {"mcp":{"servers":[
>   {"server":"Slack","tools":["slack_search_channels","slack_search_public_and_private","slack_read_channel","slack_search_users"]},
>   {"server":"Google Calendar","tools":["list_events"]},
>   {"server":"Gmail","tools":["search_threads","get_thread"]},
>   {"server":"Official Fathom","tools":["list_meetings","get_meeting_summary","get_recording_by_url","find_person"]},
>   {"server":"Omni Analytics","tools":["searchOmniDocs"]}]},
>  "sample":{}}
> ```

The capabilities have to be passed when the page is published, because they aren't stored in the HTML file. They list exactly which read-only connector tools the page is allowed to call. `sample` lets the page ask Claude questions; it powers the summaries, briefs and chats.

### 3. Approve permissions

The first time you open the published page, claude.ai asks you to approve each connector. Every tool the page uses only reads data. Nothing sends email, posts to Slack or changes your calendar.

## How a few things work

- **AE detection:** the page builds a list of AEs from Slack profile titles containing "Account Executive" or "AE". A trial's AE is whichever of them appears most often on that trial's Fathom calls from the last 90 days.
- **Fathom calls:** the page includes calls you recorded, plus calls you spoke on that someone else recorded. Action items are only available for calls you recorded.
- **Matching calls to trials:** a call counts toward a trial if its title or prospect email domain matches the trial's channel name. For example, `#omni-acme-evaluation` matches "Acme + Omni" calls and `@acme.com` attendees.
- **Saved in your browser:** your theme, which sections are open, trial end dates you set, trial chat history, and the AE list (cached for a week). Clearing your browser's site data resets all of these.

## Updating

If you change the page in Claude, ask Claude for the latest `index.html` and commit it here. The published artifact and this repo don't sync automatically.
