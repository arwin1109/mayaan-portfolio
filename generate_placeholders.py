#!/usr/bin/env python3
"""
Quick script to generate placeholder images for the gallery.
Run once to populate assets/images/ with placeholder PNGs.
Delete a placeholder once you add the real photo.
"""
import os, struct, zlib

def make_png(width, height, r, g, b, text=""):
    """Create a minimal solid-color PNG in memory."""
    def chunk(name, data):
        c = struct.pack('>I', len(data)) + name + data
        return c + struct.pack('>I', zlib.crc32(c[4:]) & 0xFFFFFFFF)

    raw = b''
    for y in range(height):
        row = b'\x00'
        for x in range(width):
            row += bytes([r, g, b, 255])
        raw += row

    compressed = zlib.compress(raw, 9)
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    return (
        b'\x89PNG\r\n\x1a\n'
        + chunk(b'IHDR', ihdr)
        + chunk(b'IDAT', compressed)
        + chunk(b'IEND', b'')
    )

images = {
    'mayaan.png':    (400, 400, 13,  27, 62),
    'run-3k.jpg':    (400, 300, 10,  40, 30),
    'run-5k.jpg':    (400, 300, 40,  10, 30),
    'gallery-1.jpg': (800, 600, 20,  10, 50),
    'gallery-2.jpg': (400, 300, 10,  20, 60),
    'gallery-3.jpg': (400, 300, 40,  15, 15),
    'gallery-4.jpg': (400, 300, 15,  40, 15),
    'gallery-5.jpg': (400, 300, 40,  30, 10),
    'gallery-6.jpg': (400, 300, 10,  30, 40),
}

out = os.path.join(os.path.dirname(__file__), 'assets', 'images')
os.makedirs(out, exist_ok=True)

for name, (w, h, r, g, b) in images.items():
    path = os.path.join(out, name)
    if not os.path.exists(path):
        png_data = make_png(w, h, r, g, b)
        # Save as PNG regardless of .jpg extension — browsers handle it fine
        with open(path, 'wb') as f:
            f.write(png_data)
        print(f'Created placeholder: {name}')
    else:
        print(f'Skipped (already exists): {name}')

print('\nDone! Replace each file in assets/images/ with the real photo.')
