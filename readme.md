[![Waffle.io - Columns and their card count](https://badge.waffle.io/lambdaone-io/kratia-centralized.svg?columns=all)](https://waffle.io/lambdaone-io/kratia-centralized)

# Kratia Demo 

The nascent distributed communities and organizations around the globe deserve a tool to help them perform, grow and succeed. 

The success of small and big communities alike is mainly determined by their ability to make decisions in collaboration. Kratia provides the blocks required to design, build and evolve successful digital governance, by offering conceptual and digital tools that enable any type of community to make decisions and automate on top of them.

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



