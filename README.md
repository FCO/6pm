🕕 - 6pm
=======

6pm is a NPM for raku

Create META6.json
-----------------

```bash
$ mkdir TestProject
$ cd TestProject/
$ 6pm init
Project name [TestProject]:
Project tags:
raku version [6.*]:
```

Locally install a Module
------------------------

```bash
$ 6pm install Heap
===> Searching for: Heap
===> Testing: Heap:ver('0.0.1')
===> Testing [OK]: Heap:ver('0.0.1')
===> Installing: Heap:ver('0.0.1')
```

Locally install a Module and add it on depends of META6.json
------------------------------------------------------------

```bash
$ 6pm install Heap --save
===> Searching for: Heap
===> Testing: Heap:ver('0.0.1')
===> Testing [OK]: Heap:ver('0.0.1')
===> Installing: Heap:ver('0.0.1')
```

Run code using the local dependencies
-------------------------------------

```bash
$ 6pm exec -- raku -MHeap -e 'say Heap.new: <q w e r>'
Heap.new: [e r q w]
```

Run a file using the local dependencies
---------------------------------------

```bash
$ echo "use Heap; say Heap.new: <q w e r>" > bla.p6
$ 6pm exec-file bla.p6
Heap.new: [e r q w]
```

Make your code always use 6pm
-----------------------------

```bash
$ echo "use SixPM; use Heap; say Heap.new: <q w e r>" > bla.p6
$ raku bla.p6
Heap.new: [e r q w]
```

Running scripts
---------------

Add your script at your META6.json scripts field and run it with:

```bash
$ cat META6.json
{
  "name": "TestProject",
  "source-url": "",
  "perl": "6.*",
  "resources": [

  ],
  "scripts": {
    "test": "zef test .",
    "my-script": "raku -MHeap -e 'say Heap.new: ^10'"
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

