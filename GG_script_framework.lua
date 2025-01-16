------------Cjian------------
data = {}
initializationChoice = {}
initializationChoice={--初始化菜单(可以为空，可以无限增加，nil不要省略)
    {1,"初始化ID为1功能"},--初始化菜单选项1，语法:{初始化ID,选项名称}
    {2,"初始化ID为2功能"},--初始化菜单选项2，语法:{初始化ID,选项名称}
    nil
}

data[1]={--功能1
    {"功能1",0,nil},--功能，语法:{功能名称,初始化ID,nil}初始化ID可以相同，写0默认进入脚本自动初始化一次，写-1功能每次开启或关闭前都会自动初始化一次
    {--修改1
        {   
            {gg.REGION_OTHER,gg.TYPE_DWORD,"16777216"},--主特征，语法:{内存,类型,特征数值}
            {0x8,gg.TYPE_DWORD,"1899529"},--副特征1，语法:{距离主特征的偏移,类型,特征数值}
            {0xC,gg.TYPE_DWORD,"131084"},--副特征2(可以无限增加)，语法:{距离主特征的偏移,类型,特征数值}
            nil
        },
        {
            {0x10,gg.TYPE_DWORD,666,true,65551},--修改值1，语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结(冻结true，不冻结false),恢复数值}
            {0x14,gg.TYPE_DWORD,888,false,8},--修改值2(可以无限增加，或者不要)，语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结(冻结true，不冻结false),恢复数值}
            nil
        },{}
    },
    {--修改2，可以不要
        {
            {gg.REGION_OTHER,gg.TYPE_DWORD,"16384"},--主特征，语法:{内存,类型,特征数值}
            nil
        },
        {
            {0x0,gg.TYPE_DWORD,999,false,16384},--修改值1，语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结(冻结true，不冻结false),恢复数值}
            nil
        },{}
    },
    nil
}

data[2]={--功能2
    {"功能2",1,nil},--功能，语法:{功能名称,初始化ID,nil}初始化ID可以相同，写0默认进入脚本自动初始化一次，写-1功能每次开启或关闭前都会自动初始化一次
    {--修改1
        {   
            {gg.REGION_OTHER,gg.TYPE_DWORD,"16777216"},--主特征，语法:{内存,类型,特征数值}
            {0x8,gg.TYPE_DWORD,"1899529"},--副特征1，语法:{距离主特征的偏移,类型,特征数值}
            {0xC,gg.TYPE_DWORD,"131084"},--副特征2(可以无限增加)，语法:{距离主特征的偏移,类型,特征数值}
            nil
        },
        {
            {0x10,gg.TYPE_DWORD,nil,true,65551},--修改值1，语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结,恢复数值}
            {0x14,gg.TYPE_DWORD,888,false,8},--修改值2(可以无限增加)，语法:{距离主特征的偏移,类型,修改数值,是否冻结,恢复数值}
            nil
        },{}
    },
    nil
}


function initialization(initializationId)
    local i = 1
    local exist = false
    while data[i] ~= nil do
        if data[i][1][2] == initializationId then
            searchValuesAddress(i)
            exist = true
        end
        i = i + 1
    end
    if exist == true then
        gg.toast("初始化完成！")
    else
        gg.toast("功能不存在！")
    end
end

function searchValuesAddress(i)
    local j = 2
    local k = 2
    local tempAddress = {}
    j = 2
    while data[i][j] ~= nil do
        data[i][j][1][1][4] = 0
        gg.clearResults()
        gg.setRanges(data[i][j][1][1][1])
        gg.searchNumber(data[i][j][1][1][3], data[i][j][1][1][2], false, gg.SIGN_EQUAL, 0, -1)
        data[i][j][3] = {}
        data[i][j][3] = gg.getResults(gg.getResultCount() + 1);
        if gg.getResultCount() == 0 then
            data[i][1][3] = false
            gg.alert(("检测到(" .. data[i][1][1] .. ")初始化失败!"))
            return
        end
        while data[i][j][1][k] ~= nil do
            local l = 1
            while data[i][j][3][l] ~= nil do
                data[i][j][3][l].address = data[i][j][3][l].address + data[i][j][1][k][1] - data[i][j][1][1][4]
                data[i][j][3][l].flags = data[i][j][1][k][2]
                l = l + 1
            end
            l = 1
            tempAddress = gg.getValues(data[i][j][3])
            data[i][j][1][1][4] = data[i][j][1][k][1]
            data[i][j][3] = nil
            data[i][j][3] = {}
            local count = 1
            while tempAddress[l] ~= nil do
                if tempAddress[l].value == data[i][j][1][k][3] then
                    data[i][j][3][count] = {}
                    data[i][j][3][count].address = tempAddress[l].address
                    data[i][j][3][count].flags = tempAddress[l].flags
                    data[i][j][3][count].value = tempAddress[l].value
                    count = count + 1
                end
                l = l + 1
            end
            if count == 1 then
                data[i][1][3] = false
                gg.alert(("检测到(" .. data[i][1][1] .. ")初始化失败!"))
                return
            end
            count = 1
            k = k + 1
        end
        j = j + 1
    end
    data[i][1][3] = true
    gg.clearResults()
end

function modify(fun, condition)
    local i = 2
    local j = 1
    local k = 1
    local inputValues = nil
    if data[fun][1][2] == -1 then
        searchValuesAddress(fun)
    end
    if condition == nil and data[fun][1][3] == true then
        while data[fun][i] ~= nil do
            j = 1
            while data[fun][i][2][j] ~= nil do
                k = 1
                while data[fun][i][3][k] ~= nil do
                    if data[fun][i][2][j][4] == true then
                        gg.addListItems({{
                            address = data[fun][i][3][k].address + data[fun][i][2][j][1] - data[fun][i][1][1][4],
                            flags = data[fun][i][2][j][2],
                            freeze = false,
                            value = data[fun][i][2][j][5]
                        }})
                        gg.setValues({{
                            address = data[fun][i][3][k].address + data[fun][i][2][j][1] - data[fun][i][1][1][4],
                            flags = data[fun][i][2][j][2],
                            value = data[fun][i][2][j][5]
                        }})
                    else
                        gg.setValues({{
                            address = data[fun][i][3][k].address + data[fun][i][2][j][1] - data[fun][i][1][1][4],
                            flags = data[fun][i][2][j][2],
                            value = data[fun][i][2][j][5]
                        }})
                    end
                    k = k + 1
                end
                j = j + 1
            end
            i = i + 1
        end
        gg.toast("修改成功!")
    elseif data[fun][1][3] == true then
        while data[fun][i] ~= nil do
            j = 1
            while data[fun][i][2][j] ~= nil do
                k = 1
                if data[fun][i][2][j][3] == nil then
                    inputValues = gg.prompt({"输入你要改的值(" .. data[fun][1][1] .. ")"}, {
                        [1] = ""
                    })
                    if inputValues == nil or inputValues[1] == "" then
                        gg.toast("你选择了取消！")
                        return false
                    end
                end
                while data[fun][i][3][k] ~= nil do
                    if data[fun][i][2][j][3] ~= nil then
                        if data[fun][i][2][j][4] == true then
                            gg.addListItems({{
                                address = data[fun][i][3][k].address + data[fun][i][2][j][1] - data[fun][i][1][1][4],
                                flags = data[fun][i][2][j][2],
                                freeze = data[fun][i][2][j][4],
                                value = data[fun][i][2][j][3]
                            }})
                        else
                            gg.setValues({{
                                address = data[fun][i][3][k].address + data[fun][i][2][j][1] - data[fun][i][1][1][4],
                                flags = data[fun][i][2][j][2],
                                value = data[fun][i][2][j][3]
                            }})
                        end
                    else
                        if data[fun][i][2][j][4] == true then
                            gg.addListItems({{
                                address = data[fun][i][3][k].address + data[fun][i][2][j][1] - data[fun][i][1][1][4],
                                flags = data[fun][i][2][j][2],
                                freeze = data[fun][i][2][j][4],
                                value = inputValues[1]
                            }})
                        else
                            gg.setValues({{
                                address = data[fun][i][3][k].address + data[fun][i][2][j][1] - data[fun][i][1][1][4],
                                flags = data[fun][i][2][j][2],
                                value = inputValues[1]
                            }})
                        end
                    end
                    k = k + 1
                end
                j = j + 1
            end
            i = i + 1
        end
        gg.toast("修改成功!")
        return true
    elseif data[fun][1][3] == nil then
        gg.toast("修改失败!未初始化!")
        return false
    else
        gg.toast("修改失败!初始化失败!")
        return false
    end
    return false
end

begin = false
function main()
    if begin == false then
        local i = 1
        initialization(0)
        choice = {}
        funCondition = {}
        while initializationChoice[i] ~= nil do
            choice[i] = initializationChoice[i][2]
            funCondition[i] = nil
            i = i + 1
        end
        initializationChoiceCount = i - 1
        while data[i - initializationChoiceCount] ~= nil do
            choice[i] = data[i - initializationChoiceCount][1][1]
            funCondition[i] = nil
            i = i + 1
        end
        funCondition[i] = nil
        choice[i] = "退出"
        begin = true
        mainExit = i
    end
    local funCondition2 = {}
    funCondition2 = gg.multiChoice(choice, funCondition)
    local funNum = 1
    if funCondition2 ~= nil then
        while funNum < mainExit do
            if funNum <= initializationChoiceCount then
                if funCondition2[funNum] == true then
                    initialization(initializationChoice[funNum][1])
                    funCondition[funNum] = nil
                end
            else
                if funCondition[funNum] ~= funCondition2[funNum] then
                    if modify(funNum - initializationChoiceCount, funCondition2[funNum]) == false then
                        funCondition2[funNum] = nil
                    end
                end
                funCondition[funNum] = funCondition2[funNum]
            end

            funNum = funNum + 1
        end
        if funCondition2[mainExit] == true then
            os.exit()
        end
    end
    visible = false
end

while true do
    if gg.isVisible(true) then
        visible = true
        gg.setVisible(false)
    end
    if visible == true then
        main()
    end
end
