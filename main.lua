--|:: intrepeter
local reg={}
local pc = 1
local functions = {[1]=print,[2]=error,[3]=io.read}
local opc = {
    [1]=function(a,b)--sets a reg
        reg[a]=b
    end;
    [2]=function(a,b,c)--add
        reg[c]=(reg[a]+reg[b])
    end;
    [3]=function(a,b,c)--sub
        reg[c]=(reg[a]-reg[b])
    end;
    [4]=function(a,b,c)--mul
        reg[c]=(reg[a]*reg[b])
    end;
    [5]=function(a,b,c)--div
        reg[c]=(reg[a]/reg[b])
    end;
    [6]=function(a,b,c)--pow
        reg[c]=(reg[a]^reg[b])
    end;
    [7]=function(a,b,c)--mod
        reg[c]=(reg[a]%reg[b])
    end;
    [8]=function(r,a,...)--call
        local args = {}
        for i,v in ipairs({...}) do
           args[i]=reg[v]
        end
        reg[r]=functions[a](table.unpack(args))
    end;
    [9]=function(n)--jump
        
        pc=pc+n-1
    end;
    [10]=function(r,n)--jump if true
        if reg[r] == true then
            pc=pc+n-1
        end
    end;
    [11]=function(o,a,b,r)--compare
        if o==">" then 
            reg[r]=reg[a]>reg[b] 
        elseif o=="<" then
            reg[r]=reg[a]<reg[b]
        elseif o=="==" then
            reg[r]=reg[a]==reg[b]
        elseif o=="!=" then
            reg[r]=reg[a]~=reg[b]
        else
            error("invalid op")
        end
    end;
    [12]=function(a,r)--not
        reg[r]=(not reg[a])
    end;
    [13]=function(a,b,r)--or
        reg[r]=reg[a] or reg[b]
    end;
    [14]=function(a,b,r)--and
        reg[r]=reg[a] and reg[b]
    end;
}


function compile(source)
    local inst = {}
    for stmt in source:gmatch("(.-):|:") do
        local opco = stmt:match("^%:.([0-9]+)|::")
        if opco then
            opco = tonumber(opco)
           -- print(opco)
            local argst = stmt:match("|::(.*)")
            local args = {}
           -- print(argst)
            if argst then
                local argcount = 0
                for argf in argst:gmatch("([^>>]+)") do
                   -- print(argf)
                    argcount=argcount+1
                    local fl = argf:sub(1,1)..argf:sub(-1)
                    local num = tonumber(argf)
                    if num then
                        args[#args+1] =  num
                    elseif fl=="''" or fl=='""' then
                        args[#args+1] = argf:sub(2,-2)
                    elseif argf=="true" then args[#args+1] = true elseif argf=="false" then args[#args+1] = false 
                    else error("invalid argument #"..argcount) end
                end
            end
            inst[#inst+1]={opcode=opco, args=args}
        end
    end
    return inst
end

function intrepet(p)
    pc = 1
    while pc <= #p do
        local instr = p[pc]
        local op = opc[instr.opcode]
        if op then
            op(table.unpack(instr.args))
        end
        pc = pc + 1
    end
end

if arg[1] == nil then
    print("|:: (Ero), the esoteric language")
    while true do
        io.write(">")
        local inp=io.read()
        local ok,res =pcall(compile,inp)
        --print(ok,table.concat(res," "))
        if not ok then io.stderr:write(res) else intrepet(res) end
    end
elseif arg[2]=="-c" then --compile 

elseif arg[2]=="-oc" then --open compiled

else
    local h=io.open(arg[1],"r")
    local c=h:read("a")h:close()
    local ok,res =pcall(compile,inp)
    if not ok then io.stderr:write(res) else intrepet(res) end
end
