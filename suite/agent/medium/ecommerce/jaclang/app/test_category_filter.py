#!/usr/bin/env python3
"""Test script to verify category filter functionality."""

import subprocess
import json
import time
import requests
import signal
import os

def start_server():
    """Start the Jac server."""
    proc = subprocess.Popen(
        ["jac", "start", "main.jac"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd="/tmp/jasecibench/suite/agent/medium/ecommerce/jaclang/app"
    )
    time.sleep(6)  # Wait for server to start
    return proc

def stop_server(proc):
    """Stop the Jac server."""
    os.kill(proc.pid, signal.SIGTERM)
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        os.kill(proc.pid, signal.SIGKILL)

def test_category_filter():
    """Test the category filter endpoint."""
    proc = start_server()
    try:
        # Test filtering by category cat_004 (Technology)
        response = requests.post(
            "http://localhost:9000/function/list_products",
            json={"category_id": "cat_004"},
            headers={"Content-Type": "application/json"}
        )
        data = response.json()
        products = data.get("data", {}).get("result", [])
        
        print(f"Total products in Technology category: {len(products)}")
        for p in products:
            print(f"  - {p['name']} (id: {p['id']})")
        
        # Expected: 2 products (Keyboard, Headphones)
        assert len(products) == 2, f"Expected 2 products, got {len(products)}"
        
        # Test all products (empty category_id)
        response = requests.post(
            "http://localhost:9000/function/list_products",
            json={"category_id": ""},
            headers={"Content-Type": "application/json"}
        )
        data = response.json()
        all_products = data.get("data", {}).get("result", [])
        
        print(f"\nTotal active products: {len(all_products)}")
        
        # Should have more than 2
        assert len(all_products) > 2, f"Expected > 2 products, got {len(all_products)}"
        
        print("\n✓ All tests passed!")
        return True
    finally:
        stop_server(proc)

if __name__ == "__main__":
    test_category_filter()
