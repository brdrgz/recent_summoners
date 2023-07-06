# RecentSummoners

## Setup
# Tests
Generate self-signed certs for the test server:
```
openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout selfsigned_key.pem -out selfsigned.pem
mkdir -p priv/cert
mv selfsigned_key.pem priv/cert
mv selfsigned.pem priv/cert
```

Add the following to your `/etc/hosts` file:
(you may replace `riotgames.local` if you have overridden the value in config)
```
127.0.0.1       br1.riotgames.local
127.0.0.1       eun1.riotgames.local
127.0.0.1       euw1.riotgames.local
127.0.0.1       jp1.riotgames.local
127.0.0.1       kr.riotgames.local
127.0.0.1       la1.riotgames.local
127.0.0.1       la2.riotgames.local
127.0.0.1       na1.riotgames.local
127.0.0.1       oc1.riotgames.local
127.0.0.1       tr1.riotgames.local
127.0.0.1       ru.riotgames.local
127.0.0.1       ph2.riotgames.local
127.0.0.1       sg2.riotgames.local
127.0.0.1       th2.riotgames.local
127.0.0.1       tw2.riotgames.local
127.0.0.1       vn2.riotgames.local
127.0.0.1       americas.riotgames.local
127.0.0.1       asia.riotgames.local
127.0.0.1       europe.riotgames.local
```
Now, export necessary env vars (you can also provide these when you run `mix test`):
```
export RIOT_API_BASE_DOMAIN=riotgames.local:8443
export RIOT_API_KEY=keygoeshere
```

Then run `mix test`

# Running
`iex -S mix` OR `RIOT_API_BASE_DOMAIN=api.riotgames.com RIOT_API_KEY=keygoeshere iex -S mix`
```
iex(1)> RecentSummoners.find("Caps", "eun1")
[..., ..., ..., ..., ...]
```