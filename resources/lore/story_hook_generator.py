import sys
import random
import os


def get_title_and_random_value(filepath):
    with open(filepath, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
    if len(lines) < 2:
        raise ValueError(f"File '{filepath}' must have at least 2 lines (title + values).")
    title = lines[0]
    value = random.choice(lines[1:])
    return title, value


def main():
    directory = "inputs"

    if not os.path.isdir(directory):
        print(f"Error: '{directory}' is not a valid directory.", file=sys.stderr)
        sys.exit(1)

    filepaths = sorted([
        os.path.join(directory, f)
        for f in os.listdir(directory)
        if os.path.isfile(os.path.join(directory, f))
    ])

    if not filepaths:
        print(f"Error: No files found in '{directory}'.", file=sys.stderr)
        sys.exit(1)

    results = []
    for filepath in filepaths:
        try:
            title, value = get_title_and_random_value(filepath)
            results.append(f"{title}: {value}")
        except Exception as e:
            print(f"Warning: Skipping '{filepath}': {e}", file=sys.stderr)

    if results:
        print(', '.join(results))


if __name__ == '__main__':
    main()