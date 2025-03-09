#!/bin/bash

# Urls and links
BASHRC="$CFG_DIR/.bashrc"
# desired output name of release
ELM_RELEASE_FOLDER="elm_0.19.1_linux-64-bit_binary"
RELEASE_FILENAME="elm_0.19.1_linux-64-bit_binary.gz"
RELEASE_URL="https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz"
# Test link
HELLO_WORLD_URL="https://github.com/roc-lang/examples/tree/main/examples/ElmWebApp"

function curl_release() {
    local download_url

    download_url=$1

    if [ -z "$download_url" ]; then
        echo "No download url provided"
        exit 1
    fi

    curl -L -o "$RELEASE_FILENAME" https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz

    mkdir $ELM_RELEASE_FOLDER

    gunzip -c $RELEASE_FILENAME >$ELM_RELEASE_FOLDER/elm

    chmod +x $ELM_RELEASE_FOLDER/elm

    return 0
}

function setup_elm_command() {
    local extracted_elm_dir
    local elm_alias_to_add

    extracted_elm_dir="$ELM_RELEASE_FOLDER"

    # local path_to_add
    path_to_add="export PATH=\$PATH:$(pwd)/$extracted_elm_dir"
    elm_alias_to_add="export alias elm=$(pwd)/$extracted_elm_dir/elm"

    # # str path_to_add from the bashrc file if it is already there
    sed -i "\|export PATH=\$PATH:$(pwd)/$extracted_elm_dir|d" "$BASHRC"
    # remove the alias if it is already there
    sed -i "\|alias elm=$(pwd)/$extracted_elm_dir/elm|d" "$BASHRC"

    echo $path_to_add >>$BASHRC
    echo $elm_alias_to_add >>$BASHRC

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
    setup_elm_command
    # download_hello_world $HELLO_WORLD_URL

    # source the bashrc file
    rm ~/.bashrc
    cp $BASHRC ~/.bashrc

    source ~/.bashrc

    # test elm version
    elm --version
}

alias main=main
main
