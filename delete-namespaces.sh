#!/usr/bin/env bash
set -e

k delete ns george-app --ignore-not-found --timeout=120s
k delete ns istio-system --ignore-not-found --timeout=120s
