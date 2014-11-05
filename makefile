all: pascal.js

pascal.js: pascal.y; jison pascal.y

clean:; rm -f pascal.js
