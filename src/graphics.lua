local graphics = {}

local old_getScissor = love.graphics.getScissor

graphics._canvases = {}
graphics._keep_canvas = {}
graphics._used_canvas = {}

graphics._scissor_stack = {}

function graphics.getCanvas(id, width, height, keep)
    graphics._used_canvas[id] = true
    graphics._keep_canvas[id] = keep
    local canvas = graphics._canvases[id]
    if not canvas or canvas[2] ~= width or canvas[3] ~= height then
        canvas = {love.graphics.newCanvas(width, height), width, height}
        graphics._canvases[id] = canvas
    end
    return canvas[1]
end

function graphics._clearUnusedCanvases()
    local remove = {}
    for k,_ in pairs(graphics._canvases) do
        if not graphics._keep_canvas[k] and not graphics._used_canvas[k] then
            table.insert(remove, k)
        end
    end
    for _,v in ipairs(remove) do
        graphics._canvases[v][1] = nil
        graphics._canvases[v] = nil
    end
end

function graphics.getScissor()
    if love.graphics.getScissor() then
        local x, y, w, h = love.graphics.getScissor()
        local x2, y2 = x + w, y + h

        x, y = love.graphics.inverseTransformPoint(x, y)
        x2, y2 = love.graphics.inverseTransformPoint(x2, y2)

        w, h = x2 - x, y2 - y

        return x, y, w, h
    else
        local x, y, w, h = 0, 0, love.graphics.getWidth(), love.graphics.getHeight()
        local x2, y2 = x + w, y + h

        x, y = love.graphics.inverseTransformPoint(x, y)
        x2, y2 = love.graphics.inverseTransformPoint(x2, y2)

        w, h = x2 - x, y2 - y

        return x, y, w, h
    end
end

function graphics.pushScissor()
    local x, y, w, h = old_getScissor()

    table.insert(graphics._scissor_stack, 1, {x, y, w, h})
end

function graphics.popScissor()
    local x, y, w, h = unpack(graphics._scissor_stack[1])

    love.graphics.setScissor(x, y, w, h)
    table.remove(graphics._scissor_stack, 1)
end

function graphics.scissor(x, y, w, h)
    local sx, sy = love.graphics.transformPoint(x, y)
    local sx2, sy2 = love.graphics.transformPoint(x+w, y+h)

    if love.graphics.getScissor() == nil then
        love.graphics.setScissor(math.min(sx, sx2), math.min(sy, sy2), math.abs(sx2-sx), math.abs(sy2-sy))
    else
        love.graphics.intersectScissor(math.min(sx, sx2), math.min(sy, sy2), math.abs(sx2-sx), math.abs(sy2-sy))
    end
end

return graphics