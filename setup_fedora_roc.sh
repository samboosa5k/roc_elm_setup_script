#!/bin/bash

# Urls and links
BASHRC="$CFG_DIR/.bashrc"
RELEASE_FILENAME="roc-linux_x86_64-alpha3-rolling.tar.gz"
RELEASE_URL="https://github.com/roc-lang/roc/releases/download/alpha3-rolling/$RELEASE_FILENAME"
# Test link
HELLO_WORLD_URL="https://raw.githubusercontent.com/roc-lang/examples/refs/heads/main/examples/HelloWorld/main.roc"

function curl_release() {
    local download_url

    download_url=$1

    if [ -z "$download_url" ]; then
        echo "No download url provided"
        exit 1
    fi

    curl -OL $download_url
    return 0
}

function extract_release() {
    local release_filename

    release_filename=$1

    if [ -z "$release_filename" ]; then
        echo "No release filename provided"
        exit 1
    fi

    tar -xvf $release_filename

    return 0
}

function setup_roc_command() {
    local extracted_roc_dir

    extracted_roc_dir=$(compgen -d -- "./roc")
    # strip ./ from the directory
    extracted_roc_dir=${extracted_roc_dir:2}

    if [ -z "$extracted_roc_dir" ]; then
        echo "No roc directory found"
        exit 1
    fi

    local path_to_add
    path_to_add="export PATH=\$PATH:$(pwd)/$extracted_roc_dir"

    # str path_to_add from the bashrc file if it is already there
    sed -i "\|export PATH=\$PATH:$(pwd)/$extracted_roc_dir|d" "$BASHRC"

    echo $path_to_add >> $BASHRC

    return 0
}

function install_last_dependencies() {
    local depdendencies_exist
    depdendencies_exist=$(rpm -q glibc-devel binutils)

    if [ -z "$depdendencies_exist" ]; then
        echo "Dependencies already installed"
        exit 0
    fi

    sudo dnf install glibc-devel binutils

    return 0
}

function download_hello_world() {
    local hello_world_url

    hello_world_url=$1

    if [ -z "$hello_world_url" ]; then
        echo "No hello world url provided"
        exit 1
    fi

    curl -OL $hello_world_url

    return 0
}

function main() {
     curl_release $RELEASE_URL
     extract_release $RELEASE_FILENAME
    setup_roc_command
     install_last_dependencies
    download_hello_world $HELLO_WORLD_URL

    # source the bashrc file
    rm ~/.bashrc
    cp $BASHRC ~/.bashrc

    source ~/.bashrc

    # run the hello world program
    roc run main.roc
}

alias main=main
main
