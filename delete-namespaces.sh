#!/usr/bin/env bash
set -e

k delete ns george-app
k delete ns istio-system
