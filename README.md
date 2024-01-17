# HiPi

Very much a WIP - initial goal is to toggle a smart outlet in my house when a Raspberry Pi powers on.

This switch turning on triggers a broadcast on Google Home that I use to know when utility power returns
while running on a generator.  (The rpi is plugged into an outlet that is hardwired to the utlity side of 
the transfer switch)

What's wrong with this / could use work:
  - Doesn't renew tokens (since it only really runs once)
  - Waits for the network to come up by just delaying - should actually hook to the state change
  - Isn't a real Req plugin (again LMK if you wanna see this broken out and made nice)
  - Should generate a real nonce (hard-coded for now)
  - Pretty much all of it, this represents a couple days effort to solve a specific problem
    - There aren't tests, or documentation, etc

What it does / works
  - Implements the mandatory parts of Tuya's request signing and request tokens to get some results
  - Runs on my Pi Zero 2 W

What it needs to run for you
  - If using on a Pi, you'll need to get the Nerves networking configured
  - For Tuya, you need a dev account and a "project" that maps to your Tuya account
    - That is, you'll need to be able to do control from the Tuya cloud console
    - You'll need to supply environment variables (see `config.exs` for details)
      - `TUYA_CLOUD_SECRET` and `TUYA_CLOUD_CLIENT_ID`, you get those from Tuya Cloud
      - `TUYA_CLOUD_BASE_URL` unless you're OK with US West coast datacenter
