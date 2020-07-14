#!/usr/bin/env bash
set -o errexit
cd R
Rscript --verbose -e "testthat::test_dir('tests')"
