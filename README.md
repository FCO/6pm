[![Build Status](https://travis-ci.org/FCO/6pm.svg?branch=master)](https://travis-ci.org/FCO/6pm)
# 🕕 - 6pm

## Create META6.json

```
$ mkdir TestProject
$ cd TestProject/
$ 6pm init
Project name [TestProject]:
Project tags:
perl6 version [6.*]:
```

## Locally install a Module

```
$ 6pm install Heap
===> Searching for: Heap
===> Testing: Heap:ver('0.0.1')
===> Testing [OK]: Heap:ver('0.0.1')
===> Installing: Heap:ver('0.0.1')
```

## Locally install a Module and add it on depends of META6.json

```
$ 6pm install Heap --save
===> Searching for: Heap
===> Testing: Heap:ver('0.0.1')
===> Testing [OK]: Heap:ver('0.0.1')
===> Installing: Heap:ver('0.0.1')
```

## Run code using the local dependencies

```
$ 6pm exec -- perl6 -MHeap -e 'say Heap.new: <q w e r>'
Heap.new: [e r q w]
```

## Run a file using the local dependencies

```
$ echo "use Heap; say Heap.new: <q w e r>" > bla.p6
$ 6pm exec-file bla.p6
Heap.new: [e r q w]
```

## Running scripts

Add your script at your META6.json scripts field and run it with:

```
$ cat META6.json
{
  "name": "TestProject",
  "source-url": "",
  "perl": "6.*",
  "resources": [

  ],
  "scripts": {
    "test": "zef test .",
    "my-script": "perl6 -MHeap -e 'say Heap.new: ^10'"
  },
  "depends": [

  ],
  "test-depends": [
    "Test",
    "Test::META"
  ],
  "provides": {

  },
  "tags": [

  ],
  "version": "0.0.1",
  "authors": [
    "fernando"
  ],
  "description": ""
}
$ 6pm run my-script
Heap.new: [0 1 2 3 4 5 6 7 8 9]
```
