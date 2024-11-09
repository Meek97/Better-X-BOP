#!/bin/bash

TAG_LIST=$(git tag --merged) #only check for tags that are reachable from the current tree
echo "All Tags:"
echo "${TAG_LIST}"

#IFS="\n"
#read -ra TAG_ARRAY <<< "$TAG_LIST"
readarray -d "
" -t TAG_ARRAY <<< $TAG_LIST

echo "---"

LATEST_DATA_MAJOR_VER=
LATEST_DATA_MINOR_VER=

LATEST_BASE_MAJOR_VER=
LATEST_BASE_MINOR_VER=
LATEST_BASE_PATCH_VER=

TAG_INDEX=""

TAG_PATTERN="(v)(\S*\.\S*)(-)(\S*\.\S*\.\S*)"
DATA_VERSION_PATTERN="(\S*)(\.)(\S*)"
BASE_VERSION_PATTERN="(\S*)(\.)(\S*)(\.)(\S*)"

# loop over our tag array to find the highest tag version
for index in ${!TAG_ARRAY[@]};
do
    val=${TAG_ARRAY[index]}
    #Capture the Data and Base version from our tag
    if [[ $val =~ $TAG_PATTERN ]]
    then
        TAG_INDEX=${index}
        DATA_VER=${BASH_REMATCH[2]}
        BASE_VER=${BASH_REMATCH[4]}

        #Split Base version into it's components
        if [[ $BASE_VER =~ $BASE_VERSION_PATTERN ]]
        then
            BASE_MAJOR_VER=$((BASH_REMATCH[1]))
            BASE_MINOR_VER=$((BASH_REMATCH[3]))
            BASE_PATCH_VER=$((BASH_REMATCH[5]))
            echo "Base ver: ${BASE_MAJOR_VER}.${BASE_MINOR_VER}.${BASE_PATCH_VER}"
        fi

        #Split Data version into it's components
        if [[ $DATA_VER =~ $DATA_VERSION_PATTERN ]]
        then
            DATA_MAJOR_VER=$((BASH_REMATCH[1]))
            DATA_MINOR_VER=$((BASH_REMATCH[3]))
            echo "Data ver: ${DATA_MAJOR_VER}.${DATA_MINOR_VER}"
        fi

        #Start comparing the version compoents to find our highest version tag
        if [[ $BASE_MAJOR_VER -ge $((LATEST_BASE_MAJOR_VER)) ]]
        then
            echo "New latest base major version!"
            LATEST_DATA_MAJOR_VER=
            LATEST_DATA_MINOR_VER=

            LATEST_BASE_MAJOR_VER=$((BASE_MAJOR_VER))
            LATEST_BASE_MINOR_VER=
            LATEST_BASE_PATCH_VER=
            #4
            if [[ $BASE_MINOR_VER -ge $((LATEST_BASE_MINOR_VER)) ]]
            then
                echo "New latest base minor version!"
                LATEST_DATA_MAJOR_VER=
                LATEST_DATA_MINOR_VER=

                #LATEST_BASE_MAJOR_VER=
                LATEST_BASE_MINOR_VER=$((BASE_MINOR_VER))
                LATEST_BASE_PATCH_VER=
                #5
                if [[ $BASE_PATCH_VER -gt $((LATEST_BASE_PATCH_VER)) ]]
                then
                    echo "New latest base patch version!"
                    LATEST_DATA_MAJOR_VER=
                    LATEST_DATA_MINOR_VER=

                    #LATEST_BASE_MAJOR_VER=
                    #LATEST_BASE_MINOR_VER=
                    LATEST_BASE_PATCH_VER=$((BASE_PATCH_VER))

                    #6
                    if [[ $DATA_MAJOR_VER -ge $((LATEST_DATA_MAJOR_VER)) ]]
                    then
                        echo "New latest data major version!"
                        LATEST_DATA_MAJOR_VER=$((DATA_MAJOR_VER))
                        LATEST_DATA_MINOR_VER=

                        #LATEST_BASE_MAJOR_VER=
                        #LATEST_BASE_MINOR_VER=
                        #LATEST_BASE_PATCH_VER=
                        
                        #7
                        if [[ $DATA_MINOR_VER -gt $((LATEST_DATA_MINOR_VER)) ]]
                        then
                            echo "New latest data minor version!"
                            #LATEST_DATA_MAJOR_VER=
                            LATEST_DATA_MINOR_VER=$((DATA_MINOR_VER))

                            #LATEST_BASE_MAJOR_VER=
                            #LATEST_BASE_MINOR_VER=
                            #LATEST_BASE_PATCH_VER=

                            echo "New latest tag: ${LATEST_DATA_MAJOR_VER}.${LATEST_DATA_MINOR_VER}-${BASE_VER}  @ ${TAG_INDEX}"
                        else
                            echo "Data version ${DATA_VER} is not a higher minor version than ${LATEST_DATA_MINOR_VER}"
                        fi
                        #:7
                    else
                        echo "Data version ${DATA_VER} is not a higher major version than ${LATEST_DATA_MAJOR_VER}"
                    fi
                    #:6
                else
                    echo "Base version ${BASE_VER} is not a higher patch version than ${LATEST_BASE_PATCH_VER}"
                fi
                #:5
            else
                echo "Base version ${BASE_VER} is not a higher minor version than ${LATEST_BASE_MINOR_VER}"
            fi
            #:4
        else
            echo "Base version ${BASE_VER} is not a higher major version than ${LATEST_BASE_MAJOR_VER}"
        fi
        #:3
    else
        echo "Tag: $val  does not match the expected tag pattern!"
    fi
    #:0
    echo "---"
done

zip -r "./distribution/Better-X-BOP_${LATEST_DATA_MAJOR_VER}.${LATEST_DATA_MINOR_VER}_${LATEST_BASE_MAJOR_VER}.${LATEST_BASE_MINOR_VER}.${LATEST_BASE_PATCH_VER}.zip" "./data" "./pack.mcmeta" "./pack.png"


