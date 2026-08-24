#!/usr/bin/env python3
# AI SQL Review using Ollama

import argparse
import ollama

def review_sql(diff_text, model='llama3.2:latest'):
    prompt = f"""You are a senior database engineer reviewing SQL code for:
- Query performance (indexes, execution plans, partitioning)
- Correctness (joins, aggregations, null handling)
- Security (SQL injection, permissions)
- Maintainability (naming, formatting, documentation)
- Dialect compatibility (MariaDB, PostgreSQL, ClickHouse)

Review the following diff and provide:
1. Critical issues (data loss, corruption, security)
2. Performance concerns (missing indexes, full scans, bad joins)
3. Correctness issues (wrong results, edge cases)
4. Dialect-specific problems
5. Suggested improvements with corrected SQL

Diff:
{diff_text}"""

    response = ollama.chat(model=model, messages=[{
        'role': 'user',
        'content': prompt
    }])
    return response['message']['content']

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--diff-file', required=True)
    parser.add_argument('--output', default='review.md')
    parser.add_argument('--model', default='llama3.2:latest')
    args = parser.parse_args()

    with open(args.diff_file, 'r') as f:
        diff = f.read()

    if not diff.strip():
        with open(args.output, 'w') as f:
            f.write("# AI SQL Review\n\nNo changes to review.")
        return

    print(f"Reviewing SQL diff with {args.model}...")
    review = review_sql(diff, args.model)

    with open(args.output, 'w') as f:
        f.write(f"# AI SQL Review (Ollama {args.model})\n\n")
        f.write(review)

    print(f"Review saved to {args.output}")

if __name__ == '__main__':
    main()
