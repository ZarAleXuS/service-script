#! /bin/bash

# --------- INPUT SERVICE ------------

validServiceName=false

while [ $validServiceName = false ]; do

    echo "$(tput setaf 3)Enter service name (camelCase):$(tput setaf 7)"
    read serviceName

    validServiceName=true

    if ! [[ $serviceName =~ ^[a-z]+([A-Z][a-z]+)*[A-Z]?$ ]]; then
        echo "$(tput setaf 1)Error: Name must be in camelCase."
        validServiceName=false
    fi
done

# --------- INPUT METHODS ------------

validMethodNames=false

while [ $validMethodNames = false ]; do

    echo "$(tput setaf 3)Enter method names (camelCase):$(tput setaf 7)"
    read -a methodNames

    validMethodNames=true

    for i in "${methodNames[@]}"; do
        if ! [[ $i =~ ^[a-z]+([A-Z][a-z]+)*[A-Z]?$ ]]; then
            echo "$(tput setaf 1)Error: Names must be in camelCase."
            validMethodNames=false
            break
        fi
    done
done

# --------- INPUT ERRORS ------------

validErrorTypes=false

while [ $validErrorTypes = false ]; do

    echo "$(tput setaf 3)Enter error types (camelCase):$(tput setaf 7)"
    read -a errorTypes

    validErrorTypes=true

    for i in "${errorTypes[@]}"; do
        if ! [[ $i =~ ^[a-z]+([A-Z][a-z]+)*[A-Z]?$ ]]; then
            echo "$(tput setaf 1)Error: Types must be in camelCase."
            validErrorTypes=false
            break
        fi
    done
done

# --------- BUILD ------------

if find build -type f | read; then
    rm -r build/*
fi

rsync -av --exclude 'block-templates' templates/ build/

# --------- OUTPUT METHODS ------------

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

ERROR="\/\*ERROR\*\/"
ERROR_TYPE="\/\*ERROR_TYPE\*\/"

for i in "${errorTypes[@]}"; do
    errorTypeSnakeUpperCase=$(echo ${i} | sed -r 's/([A-Z])/_\1/g' | tr '[:lower:]' '[:upper:]')
    errorTypeConstants+=" | '""$errorTypeSnakeUpperCase""'"
    errors+=\\n$(sed -e "s/errorType/$i/g" -e "s/ERROR_TYPE/$errorTypeSnakeUpperCase/g" templates/service-name/block-templates/error.js)\\n
done

errors=$(echo "$errors" | sed '1d' | sed '$d' | sed '$ ! s/$/\\/')

sed -i '' -e "s/"$ERROR_TYPE"/$errorTypeConstants/g" -e "s/"$ERROR"/$errors/g" build/service-name/service-name.error.js

# --------- OUTPUT SERVICE ------------

serviceNamePascal=$(echo $(echo "${serviceName:0:1}" | tr '[a-z]' '[A-Z]')"${serviceName:1}")
serviceNameKebab=$(echo "$serviceName" | sed -r 's/([A-Z])/-\1/g' | tr '[:upper:]' '[:lower:]')

mv build/service-name build/${serviceNameKebab}

for file in build/*/service-name*.**; do
    mv "$file" "${file/service-name/${serviceNameKebab}}"
done

find build/** -type f | xargs sed -i '' -e "s/serviceName/"${serviceName}"/g" -e "s/service-name/"${serviceNameKebab}"/g" -e "s/ServiceName/"${serviceNamePascal}"/g"

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
