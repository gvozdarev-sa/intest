# Intest 
Intest -  perl framework for creating testing systems. It was created for intel ilab students laboratory at MIPT.
#######################
Each test can include test and subtests. Differences between them is that subtest must contains driver - perl module with a sub Run and test is like container which can be launced by intest.pl. So the simplest test must contain one subtest.

The whole system are configured via json files in config dir. The structure of config is:
config/tests.json               - list of all tests
config/subtests.jsob            - list of all subtests
config/tests/*.json             - description of tests from tests.json
config/subtests/*.json          - description of subtests from the subtests.json
config/subtests/driver/*.pm     - drivers for the subtests

To run:
-----------------------
```bash
perl intest.pl --test <testname> [--debug] [--verbose] [--color]
```

For further information please see github wiki.
------------------------

Perl libs dependencies:
------------------------
- Capture::Tiny
- Data::Dumper
- JSON
- Getopt::Long


------------------------
Copyright (C) 2013 Sergey Gvozdarev https://github.com/gvozdarev-sa/intest

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



