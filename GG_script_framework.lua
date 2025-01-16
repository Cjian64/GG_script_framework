funData = {}
initializationChoice = {}

initializationChoice={--初始化菜单(可以为空,可以无限增加)
    {1,"初始化ID为1的功能"},--初始化菜单选项1,语法:{初始化ID,选项名称}
    {2,"初始化ID为2的功能"}--初始化菜单选项2,语法:{初始化ID,选项名称}
}

funData[1]={--功能1
    {"功能1",0},--功能,语法:{功能名称,初始化ID}初始化ID可以相同,写0默认进入脚本自动初始化一次,写-1功能每次开启或关闭前都会自动初始化一次
    {--修改1(修改至少需要一个,可以无限增加)
        {   
            {gg.REGION_OTHER,gg.TYPE_DWORD,"16777216"},--主特征,语法:{内存,类型,特征数值}
            {-0x4,gg.TYPE_DWORD,"524288"},--副特征1,语法:{距离主特征的偏移,类型,特征数值}
            {-0x8,gg.TYPE_DWORD,"16384"},--副特征2(可以无限增加),语法:{距离主特征的偏移,类型,特征数值}
        },
        {
            {-0x10,gg.TYPE_DWORD,666,true,14368},--修改值1(修改值必须存在一个,可以无限增加),语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结(冻结true,不冻结false),恢复数值}
            {-0x14,gg.TYPE_DWORD,888,false,34049},--修改值2(可以无限增加,或者不要),语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结(冻结true,不冻结false),恢复数值}
        }
    },
    {--修改2(修改可以无限增加或者不要)
        {
            {gg.REGION_OTHER,gg.TYPE_DWORD,"16385"},--主特征,语法:{内存,类型,特征数值}
        },
        {
            {0x0,gg.TYPE_DWORD,999,false,16385},--修改值1,语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结(冻结true,不冻结false),恢复数值}
        }
    }
}

funData[2]={--功能2
    {"功能2",1},--功能,语法:{功能名称,初始化ID}初始化ID可以相同,写0默认进入脚本自动初始化一次,写-1功能每次开启或关闭前都会自动初始化一次
    {--修改1
        {   
            {gg.REGION_OTHER,gg.TYPE_DWORD,"16777216"},--主特征,语法:{内存,类型,特征数值}
            {-0x4,gg.TYPE_DWORD,"524288"},--副特征1,语法:{距离主特征的偏移,类型,特征数值}
            {-0x8,gg.TYPE_DWORD,"16384"},--副特征2(可以无限增加),语法:{距离主特征的偏移,类型,特征数值}
        },
        {
            {-0x10,gg.TYPE_DWORD,nil,true,14368},--修改值1,语法:{距离主特征的偏移,类型,修改数值(写nil由用户输入),是否冻结,恢复数值}
            {-0x14,gg.TYPE_DWORD,888,false,34049},--修改值2(可以无限增加),语法:{距离主特征的偏移,类型,修改数值,是否冻结,恢复数值}
        }
    }
}


function initialization(initializationId)
    local i = 1
    local exist = false
    while funData[i] ~= nil do
        if funData[i][1][2] == initializationId then
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
    funData[i][1][6]=false
    funData[i][1][4]=false
    funData[i][1][5]=false
    while funData[i][j] ~= nil do
        funData[i][j][1][1][4] = 0
        gg.clearResults()
        gg.setRanges(funData[i][j][1][1][1])
        gg.searchNumber(funData[i][j][1][1][3], funData[i][j][1][1][2], false, gg.SIGN_EQUAL, 0, -1)
        funData[i][j][3] = {}
        funData[i][j][3] = gg.getResults(gg.getResultCount() + 1);
        if gg.getResultCount() == 0 then
            funData[i][1][3] = false
            gg.alert(("检测到(" .. funData[i][1][1] .. ")初始化失败!"))
            return
        end
        while funData[i][j][1][k] ~= nil do
            local l = 1
            while funData[i][j][3][l] ~= nil do
                funData[i][j][3][l].address = funData[i][j][3][l].address + funData[i][j][1][k][1] - funData[i][j][1][1][4]
                funData[i][j][3][l].flags = funData[i][j][1][k][2]
                l = l + 1
            end
            l = 1
            tempAddress = gg.getValues(funData[i][j][3])
            funData[i][j][1][1][4] = funData[i][j][1][k][1]
            funData[i][j][3] = nil
            funData[i][j][3] = {}
            local count = 1
            while tempAddress[l] ~= nil do
                if tempAddress[l].value == funData[i][j][1][k][3] then
                    funData[i][j][3][count] = {}
                    funData[i][j][3][count].address = tempAddress[l].address
                    funData[i][j][3][count].flags = tempAddress[l].flags
                    funData[i][j][3][count].value = tempAddress[l].value
                    count = count + 1
                end
                l = l + 1
            end
            if count == 1 then
                funData[i][1][3] = false
                gg.alert(("检测到(" .. funData[i][1][1] .. ")初始化失败!"))
                return
            end
            count = 1
            k = k + 1
        end
        j = j + 1
    end
    funData[i][1][3] = true
    gg.clearResults()
end

function modify(fun, condition)
    local i = 2
    local j = 1
    local k = 1
    local inputValues = nil
    local minModifyvalue=0
    local maxModifyvalue=0
    if funData[fun][1][2] == -1 then
        searchValuesAddress(fun)
    end
    if condition == nil and funData[fun][1][3] == true then
        while funData[fun][i] ~= nil do
            j = 1
            while funData[fun][i][2][j] ~= nil do
                if funData[fun][1][5] ~=true then
                    k = 1
                    funData[fun][i][2][j][7]={}
                    while funData[fun][i][3][k] ~= nil do
                        funData[fun][i][2][j][7][k]={}
                        funData[fun][i][2][j][7][k].address = funData[fun][i][3][k].address + funData[fun][i][2][j][1] - funData[fun][i][1][1][4]
                        funData[fun][i][2][j][7][k].flags = funData[fun][i][2][j][2]
                        funData[fun][i][2][j][7][k].freeze = false
                        funData[fun][i][2][j][7][k].value = funData[fun][i][2][j][5]
                        k = k + 1
                    end
                end
                if funData[fun][i][2][j][4] == true then
                    gg.addListItems(funData[fun][i][2][j][7])
                    gg.setValues(funData[fun][i][2][j][7])
                else
                    gg.setValues(funData[fun][i][2][j][7])
                end
                j = j + 1
            end
            i = i + 1
        end
        funData[fun][1][5]=true
        funData[fun][1][6]=false
        gg.toast(funData[fun][1][1].."关闭成功!")
    elseif funData[fun][1][3] == true then
        while funData[fun][i] ~= nil do
            j = 1
            while funData[fun][i][2][j] ~= nil do
                if funData[fun][i][2][j][2]==gg.TYPE_DWORD then
                        minModifyvalue=-2147483648
                        maxModifyvalue=4294967295
                    elseif funData[fun][i][2][j][2]==gg.TYPE_FLOAT then
                        minModifyvalue=-3.4e38
                        maxModifyvalue=3.4e38
                    elseif funData[fun][i][2][j][2]==gg.TYPE_DOUBLE then
                        minModifyvalue=-1.79769313486e308
                        maxModifyvalue=1.79769313486e308
                    elseif funData[fun][i][2][j][2]==gg.TYPE_WORD then
                        minModifyvalue=-32768
                        maxModifyvalue=65535
                    elseif funData[fun][i][2][j][2]==gg.TYPE_BYTE then
                        minModifyvalue=-128
                        maxModifyvalue=255
                    elseif funData[fun][i][2][j][2]==gg.TYPE_QWORD then
                        minModifyvalue=-9223372036854775808
                        maxModifyvalue=18446744073709551615
                    elseif funData[fun][i][2][j][2]==gg.TYPE_XOR then
                        minModifyvalue=-2147483648
                        maxModifyvalue=4294967295
                end
                if funData[fun][i][2][j][3] == nil then
                    ::inputValue::
                    inputValues = gg.prompt({"《"..funData[fun][1][1].."》\n".."输入你要改的值("..minModifyvalue.."~"..maxModifyvalue..")"}, {
                        [1] = ""
                    })
                    if inputValues == nil or inputValues[1] == "" then
                        gg.toast("你选择了取消！")
                        return false
                    elseif tonumber(inputValues[1])==nil then
                        gg.alert("请输入数字！")
                        goto inputValue
                    end
                    
                    inputValues[1]=tonumber(inputValues[1])
                    if inputValues[1]<minModifyvalue or inputValues[1]>maxModifyvalue then
                        gg.alert("数值溢出!请重新输入!")
                        goto inputValue
                    end
                end
                    if funData[fun][i][2][j][3] ~= nil then
                        if funData[fun][1][4] ~=true then
                            k = 1
                            funData[fun][i][2][j][6]={}
                            while funData[fun][i][3][k] ~= nil do
                                funData[fun][i][2][j][6][k]={}
                                funData[fun][i][2][j][6][k].address = funData[fun][i][3][k].address + funData[fun][i][2][j][1] - funData[fun][i][1][1][4]
                                funData[fun][i][2][j][6][k].flags = funData[fun][i][2][j][2]
                                funData[fun][i][2][j][6][k].freeze = funData[fun][i][2][j][4]
                                funData[fun][i][2][j][6][k].value = funData[fun][i][2][j][3]
                                k = k + 1
                            end
                        end
                        if funData[fun][i][2][j][4] == true then
                            gg.addListItems(funData[fun][i][2][j][6])
                        else
                            gg.setValues(funData[fun][i][2][j][6])
                        end
                    else
                        if funData[fun][1][4] ~=true then
                            k = 1
                            funData[fun][i][2][j][6]={}
                            while funData[fun][i][3][k] ~= nil do
                                funData[fun][i][2][j][6][k]={}
                                funData[fun][i][2][j][6][k].address = funData[fun][i][3][k].address + funData[fun][i][2][j][1] - funData[fun][i][1][1][4]
                                funData[fun][i][2][j][6][k].flags = funData[fun][i][2][j][2]
                                funData[fun][i][2][j][6][k].freeze = funData[fun][i][2][j][4]
                                funData[fun][i][2][j][6][k].value = inputValues[1]
                                k = k + 1
                            end
                        end
                        if funData[fun][i][2][j][4] == true then
                            gg.addListItems(funData[fun][i][2][j][6])
                        else
                            gg.setValues(funData[fun][i][2][j][6])
                        end
                    end
                j = j + 1
            end
            i = i + 1
        end
        funData[fun][1][4]=true
        funData[fun][1][6]=true
        gg.toast(funData[fun][1][1].."开启成功!")
        return true
    elseif funData[fun][1][3] == nil then
        gg.toast(funData[fun][1][1].."开启失败!未初始化!")
        return false
    else
        gg.toast(funData[fun][1][1].."开启失败!初始化失败!")
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
        while funData[i - initializationChoiceCount] ~= nil do
            choice[i] = funData[i - initializationChoiceCount][1][1]
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
                    local j=1
                    while funData[j]~=nil do
                        if funData[j][1][2]==initializationChoice[funNum][1] then
                            if funData[j][1][6]==true then
                                modify(j,nil)
                            end
                            funCondition2[initializationChoiceCount+j]=nil
                        end
                        j=j+1
                    end
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
            local ExitCount=1
            while funData[ExitCount]~=nill do
                if funData[ExitCount][1][6]==true then
                    modify(ExitCount,nil)
                end
                ExitCount=ExitCount+1
            end
            gg.clearResults()
            gg.clearList()
            print("功能已全部关闭完成!\n感谢您的使用!")
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
