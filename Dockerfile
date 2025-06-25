# Build stage - Godot export
FROM barichello/godot-ci:4.3 AS builder

# Install dependencies for headless export
RUN apt-get update && apt-get install -y \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy project files
COPY . .

# Create export directory
RUN mkdir -p export/html5

# Export to HTML5 using headless mode
RUN godot --headless --export-release "HTML5" export/html5/index.html || \
    (echo "Export failed, creating export presets..." && \
    mkdir -p .godot && \
    echo "[preset.0]

name=\"HTML5\""
platform=\"Web\"
runnable=true
dedicated_server=false
custom_features=\"\"
export_filter=\"all_resources\"
include_filter=\"\"
exclude_filter=\"\"
export_path=\"export/html5/index.html\"
encryption_include_filters=\"\"
encryption_exclude_filters=\"\"
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=\"\"
custom_template/release=\"\"
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=\"\"
html/head_include=\"\"
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=true
progressive_web_app/offline_page=\"\"
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=\"\"
progressive_web_app/icon_180x180=\"\"
progressive_web_app/icon_512x512=\"\"
progressive_web_app/background_color=Color(0, 0, 0, 1)" > export_presets.cfg && \
    godot --headless --export-release "HTML5" export/html5/index.html)

# Serve stage - nginx
FROM nginx:alpine

# Copy exported files
COPY --from=builder /app/export/html5 /usr/share/nginx/html

# Configure nginx for proper MIME types and CORS
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    location / { \
        try_files $uri $uri/ =404; \
        add_header Cross-Origin-Embedder-Policy "require-corp"; \
        add_header Cross-Origin-Opener-Policy "same-origin"; \
    } \
    \
    location ~ \.wasm$ { \
        add_header Content-Type application/wasm; \
        add_header Cross-Origin-Embedder-Policy "require-corp"; \
        add_header Cross-Origin-Opener-Policy "same-origin"; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]