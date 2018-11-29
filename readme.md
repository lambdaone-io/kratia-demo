# Kratia demo application

## Setup

- [Install Elm](http://elm-lang.org/install)
- [Install Node](https://nodejs.org/en/download/)
- [Install Yarn](https://yarnpkg.com/)

Install node packages:

```
yarn
```

## Running the application:

In terminal run:

```
yarn start
```

Open `http://localhost:3000`

## Continuous Delivery

Webpack doesn't work with Elm .19. Run locally with `yarn.start`.


# Local development

Install nginx, configure:

      server {
          listen 9090;
          server_name kratia.127.0.0.1.xip.io;

          location / {
            proxy_set_header Host $host;
            proxy_pass http://localhost:8000;
          }
          location /api {
            proxy_set_header Host $host;
            proxy_pass http://localhost:8080;
          }
        }

Start the backend to listne at 8080, run `yarn start`, go to ` http://kratia.127.0.0.1.xip.io:9090/`



