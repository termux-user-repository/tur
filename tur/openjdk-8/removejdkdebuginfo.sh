#!/bin/bash
set -e

if [[ "$TARGET_JDK" == "arm" ]]; then
  export TARGET_JDK=aarch32
fi

imagespath=openjdk/build/${JVM_PLATFORM}-${TARGET_JDK}-normal-${JVM_VARIANTS}-${JDK_DEBUG_LEVEL}/images

rm -rf dizout jreout/${TARGET_SHORT} jdkout/${TARGET_SHORT}
mkdir -p dizout jreout/${TARGET_SHORT} jdkout/${TARGET_SHORT}

cp -r $imagespath/j2re-image/* jreout/${TARGET_SHORT}/
cp -r $imagespath/j2sdk-image/* jdkout/${TARGET_SHORT}/

if [[ "$TARGET_JDK" == "x86" ]]; then
  export TARGET_JDK=i386
fi

mv jdkout/${TARGET_SHORT}/jre/lib/${TARGET_JDK}/libfreetype.so.6 jdkout/${TARGET_SHORT}/lib/${TARGET_JDK}/libfreetype.so || echo "Move exit $?"
mv jreout/${TARGET_SHORT}/lib/${TARGET_JDK}/libfreetype.so.6 jreout/${TARGET_SHORT}/lib/${TARGET_JDK}/libfreetype.so || echo "Move exit $?"

find jreout/${TARGET_SHORT} -name "*.diz" -delete
find jdkout/${TARGET_SHORT} -name "*.diz" -exec mv {} dizout/ \;


