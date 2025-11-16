#!/usr/bin/env bash

for module in */; do
  [ -d "$module" ] || continue
  terraform-docs $module
done
