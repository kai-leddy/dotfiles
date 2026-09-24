function AABtoAPK --description 'convert a Rest Less .aab to an .apk'
    set tempdir (mktemp -d) # create temp dir for .apks
    trap 'rm -rf $tempdir' EXIT # make sure it gets cleaned up

    # actually convert the aab to apks
    java -jar ~/bundletool-all-1.11.0.jar build-apks \
        --ks=~/repos/native-app/android/app/RestLess-App.jks \
        --ks-pass='pass:b00d4469e4ba470299f287212b41d42b' \
        --ks-key-alias='QDM4M3Byb2plY3QvUmVzdExlc3MtQXBw' \
        --key-pass='pass:744fc209d0c84ad6bc015f5b4476b7c3' \
        --overwrite \
        --mode=universal \
        --bundle=$argv[1] \
        --output=$tempdir/app.apks
    # unzip and move the universal apk to the requested output location
    unzip -p $tempdir/app.apks universal.apk >$argv[2]
end
