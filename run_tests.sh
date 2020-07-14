#!/usr/bin/env bash
set -e

cd R
Rscript --verbose -e "testthat::test_dir('tests')"
