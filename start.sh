#! /bin/bash

# --------- INPUT SERVICE ------------Í

clear

while true; do

    echo "$(tput setaf 8)Enter service name (camelCase):$(tput setaf 7)"
    read serviceName

    if ! [[ $serviceName =~ ^[a-z]+([A-Z][a-z]+)*[A-Z]?$ ]]; then
        echo "$(tput setaf 1)Error: Name must be in camelCase."
    else
        break
    fi
done

# --------- INPUT METHODS ------------

methodIndex=0
declare -a methodNames
declare -a methodParams

while true; do

    clear
    echo "$(tput setaf 8)Service: $(tput setaf 2)$serviceName$(tput setaf 7)"

    for i in "${!methodNames[@]}"; do
        echo "  $(tput setaf 8)Method #"$(($i + 1))": $(tput setaf 6)"${methodNames[$i]}"$(tput setaf 8) => params: ($(tput setaf 3)"${methodParams[$i]}"$(tput setaf 8))$(tput setaf 7)"
    done

    # --------- INPUT METHOD NAME ------------

    while true; do
        echo "$(tput setaf 8)Enter new method name (camelCase) [ $(tput setaf 7)Q$(tput setaf 8) to exit ] :$(tput setaf 7)"
        read methodName

        if ! [[ $methodName =~ ^[a-z]+([A-Z][a-z]+)*[A-Z]?$ ]]; then
            echo "$(tput setaf 1)Error: Name must be in camelCase.$(tput setaf 7)"
        else
            if [ "$methodName" = 'q' ]; then
                if ((${#methodNames[@]})); then
                    break 2
                else
                    echo "$(tput setaf 1)Error: Service must have at least one method.$(tput setaf 7)"
                fi
            else
                break
            fi
        fi
    done

    methodNames[methodIndex]="$methodName"

    params=''

    while true; do
        clear
        echo "$(tput setaf 8)Service: $(tput setaf 2)$serviceName$(tput setaf 7)"

        for i in "${!methodNames[@]}"; do
            echo "  $(tput setaf 8)Method #"$(($i + 1))": $(tput setaf 6)"${methodNames[$i]}"$(tput setaf 8) => params: ("${methodParams[$i]}"$(tput setaf 8))$(tput setaf 7)"
        done

        echo "$(tput setaf 8)New method: $(tput setaf 6)$methodName$(tput setaf 7)"

        # --------- INPUT PARAMETER TYPE ------------

        PS3="$(tput setaf 8)Select new parameter type: $(tput setaf 7)"

        select opt in boolean number string custom "next method"; do
            case $opt in
            boolean | number | string)
                newParamType="$opt"
                break
                ;;
            custom)
                newParamType="__BLANK__"
                break
                ;;
            "next method")
                break 2
                ;;
            *)
                echo "$(tput setaf 1)Invalid option $REPLY$(tput setaf 7)"
                ;;
            esac
        done

        # --------- INPUT PARAMETER NAME ------------

        while true; do

            echo "$(tput setaf 8)Enter $(tput setaf 2)"$opt"$(tput setaf 8) parameter name (camelCase):$(tput setaf 7)"
            read newParamName

            if ! [[ $newParamName =~ ^[a-z]+([A-Z][a-z]+)*[A-Z]?$ ]]; then
                echo "$(tput setaf 1)Error: Name must be in camelCase.$(tput setaf 7)"
            else
                break
            fi
        done

        params+="$(tput setaf 7)"$newParamName": $(tput setaf 2)"$newParamType"$(tput setaf 8), "

        methodParams[methodIndex]="$(tput setaf 7){ ""$params""$(tput setaf 7)}"
    done

    methodIndex=$((methodIndex + 1))
done

# --------- INPUT ERRORS ------------

validErrorTypes=false

while [ $validErrorTypes = false ]; do

    clear
    echo "$(tput setaf 8)Service: $(tput setaf 2)$serviceName$(tput setaf 7)"

    for i in "${!methodNames[@]}"; do
        echo "  $(tput setaf 8)Method #"$(($i + 1))": $(tput setaf 6)"${methodNames[$i]}"$(tput setaf 8) => params: ("${methodParams[$i]}"$(tput setaf 8))$(tput setaf 7)"
    done

    echo "$(tput setaf 8)Enter error types (camelCase and space-separated):$(tput setaf 7)"
    read -a errorTypes

    validErrorTypes=true

    for i in "${errorTypes[@]}"; do
        if ! [[ $i =~ ^[a-z]+([A-Z][a-z]+)*[A-Z]?$ ]]; then
            echo "$(tput setaf 1)Error: Types must be in camelCase.$(tput setaf 7)"
            validErrorTypes=false
            break
        fi
    done
done

# --------- BUILD ------------

echo "$(tput setaf 3)Creating build directory...$(tput setaf 7)"

if find build -type f | read; then
    rm -r build/*
fi

rsync -av --exclude 'block-templates' templates/ build/

# --------- OUTPUT METHODS ------------

echo "$(tput setaf 3)Building methods...$(tput setaf 7)"

METHOD="\/\*METHOD\*\/"
METHOD_IMPORTS="\/\*METHOD_IMPORTS\*\/"
METHOD_TYPES="\/\*METHOD_TYPES\*\/"
METHOD_INTERFACE="\/\*METHOD_INTERFACE\*\/"
METHOD_MOCK="\/\*METHOD_MOCK\*\/"
METHOD_PARAMS="\/\*METHOD_PARAMS\*\/"
METHOD_DESCRIBE="\/\*METHOD_DESCRIBE\*\/"

for i in "${methodNames[@]}"; do
    methodNamePascal=$(echo $(echo ${i:0:1} | tr '[a-z]' '[A-Z]')${i:1})
    methodImports+=$(sed "s/MethodName/$methodNamePascal/g" templates/service-name/block-templates/method-imports.js)\\n
    methods+=\\n$(sed -e "s/methodName/$i/g" -e "s/MethodName/$methodNamePascal/g" templates/service-name/block-templates/method.js)\\n
    methodTypes+=\\n$(sed "s/MethodName/$methodNamePascal/g" templates/service-name/block-templates/method-types.js)\\n
    methodInterfaces+=\\n$(sed -e "s/methodName/$i/g" -e "s/MethodName/$methodNamePascal/g" templates/service-name/block-templates/method-interface.js)\\n
    methodMocks+=\\n$(sed -e "s/methodName/$i/g" -e "s/MethodName/$methodNamePascal/g" templates/mock/block-templates/method-mock.js)\\n
    methodParams+=$(sed "s/MethodName/$methodNamePascal/g" templates/tests/block-templates/method-params.js)\\n
    methodDescribes+=\\n$(sed -e "s/methodName/$i/g" -e "s/MethodName/$methodNamePascal/g" templates/tests/block-templates/method-describe.js)\\n
done

methodImports=$(echo "$methodImports" | sed '$d' | sed '$ ! s/$/\\/')
methods=$(echo "$methods" | sed '$d' | sed '$ ! s/$/\\/')
methodTypes=$(echo "$methodTypes" | sed '$d' | sed '$ ! s/$/\\/')
methodInterfaces=$(echo "$methodInterfaces" | sed '1d' | sed '$d' | sed '$ ! s/$/\\/')
methodMocks=$(echo "$methodMocks" | sed '1d' | sed '$d' | sed '$ ! s/$/\\/')
methodParams=$(echo "$methodParams" | sed '$d' | sed '$ ! s/$/\\/')
methodDescribes=$(echo "$methodDescribes" | sed '$d' | sed '$ ! s/$/\\/')

sed -i '' "s/"$METHOD_TYPES"/$methodTypes/g" build/service-name/index.flow.js
sed -i '' -e "s/"$METHOD_IMPORTS"/$methodImports/g" -e "s/"$METHOD"/$methods/g" build/service-name/service-name.service.js
sed -i '' -e "s/"$METHOD_IMPORTS"/$methodImports/g" -e "s/"$METHOD_INTERFACE"/$methodInterfaces/g" build/service-name/service-name.interface.js
sed -i '' -e "s/"$METHOD_IMPORTS"/$methodImports/g" -e "s/"$METHOD_MOCK"/$methodMocks/g" build/mock/service-name-service.js
sed -i '' -e "s/"$METHOD_PARAMS"/$methodParams/g" -e "s/"$METHOD_DESCRIBE"/$methodDescribes/g" build/tests/service-name.service.test.js

# --------- OUTPUT ERRORS ------------

echo "$(tput setaf 3)Building error types...$(tput setaf 7)"

ERROR="\/\*ERROR\*\/"
ERROR_TYPE="\/\*ERROR_TYPE\*\/"

if ((${#errorTypes[@]})); then
    for i in "${!errorTypes[@]}"; do
        errorTypeSnakeUpperCase=$(echo "${errorTypes[$i]}" | sed -r 's/([A-Z])/_\1/g' | tr '[:lower:]' '[:upper:]')
        if [ $i -ne 0 ]; then
            errorTypeConstants+=" | "
        fi
        errorTypeConstants+="'""$errorTypeSnakeUpperCase""'"
        errors+=\\n$(sed -e "s/errorType/"${errorTypes[$i]}"/g" -e "s/ERROR_TYPE/$errorTypeSnakeUpperCase/g" templates/service-name/block-templates/error.js)\\n
    done

    errorTypeConstants="GenericErrorType<"$errorTypeConstants"> | "
    errors=$(echo "$errors" | sed '1d' | sed '$d' | sed '$ ! s/$/\\/')\\n\\n

    sed -i '' -e "s/"$ERROR_TYPE"/$errorTypeConstants/g" -e "s/"$ERROR"/$errors/g" build/service-name/service-name.error.js
else
    sed -i '' -e "s/"$ERROR_TYPE"//g" -e "s/"$ERROR"//g" build/service-name/service-name.error.js
fi

# --------- OUTPUT SERVICE ------------

echo "$(tput setaf 3)Building service...$(tput setaf 7)"

serviceNamePascal=$(echo $(echo "${serviceName:0:1}" | tr '[a-z]' '[A-Z]')"${serviceName:1}")
serviceNameKebab=$(echo "$serviceName" | sed -r 's/([A-Z])/-\1/g' | tr '[:upper:]' '[:lower:]')

mv build/service-name build/${serviceNameKebab}

for file in build/*/service-name*.**; do
    mv "$file" "${file/service-name/${serviceNameKebab}}"
done

find build/** -type f | xargs sed -i '' -e "s/serviceName/"${serviceName}"/g" -e "s/service-name/"${serviceNameKebab}"/g" -e "s/ServiceName/"${serviceNamePascal}"/g"

echo "$(tput setaf 2)Service created!"

# Regex:
#   - camelCase => [a-z]+([A-Z][a-z]+)*[A-Z]?
#   - PascalCase => [A-Z]([a-z]+[A-Z][a-z]*)*
#   - SNAKE_UPPER_CASE => [A-Z]+(_[A-Z]+)*
#   - kebab-case => [a-z]+(-[a-z]+)*
#   - \b ... \b => [[:\<:]] ... [[:\>:]]
#   - ^ ... $
#   - camelCase to kebab-case => echo ${names[0]} | sed -r 's/([A-Z])/-\1/g' | tr '[:upper:]' '[:lower:]'
#   - camelCase to PascalCase => $(echo ${names[0]:0:1} | tr '[a-z]' '[A-Z]')${names[0]:1}
#   - camelCase to SNAKE_UPPER_CASE => echo ${names[0]} | sed -r 's/([A-Z])/_\1/g' | tr '[:lower:]' '[:upper:]'
