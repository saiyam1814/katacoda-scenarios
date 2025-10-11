#!/bin/bash

# Verify step 7 - Cleanup and next steps
echo "🔍 Verifying cleanup and next steps..."

# This is a completion step, so we just verify the workshop was successful
echo "✅ Workshop completed successfully!"

# Check if cleanup commands were run (optional)
if [ ! -d "/root/workspace/llm-workshop" ]; then
    echo "✅ Workshop files cleaned up"
else
    echo "⚠️  Workshop files still exist (optional cleanup)"
fi

# Check if vcluster was deleted
if ! kubectl get pods -l app=vcluster -n default > /dev/null 2>&1; then
    echo "✅ vcluster cleaned up"
else
    echo "⚠️  vcluster still exists (may be in cleanup process)"
fi

echo "✅ Step 7 verification completed successfully!"
echo "🎉 Congratulations on completing the LLM on Kubernetes workshop!"
