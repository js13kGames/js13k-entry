window.Dungeon =
    generate: ->
        params =
            seed: byId('seed').value
            width: byId('width').value
            height: byId('height').value
            tileSize: byId('tile-size').value
            initialDensity: byId('initial-density').value
            reseedDensity: byId('reseed-density').value
            smoothCorners: byId('smooth').checked
            reseedMethod: byId('reseed-method').value
            emptyTolerance: byId('empty-tolerance').value
            wallRoughness: byId('wall-roughness').value
            passes: []
            generator: true

        for i in [1..6]
            value = byId('pass-'+i).value
            params.passes.push value unless value == ''
        console.log params.passes
        byId('params').innerHTML = JSON.stringify(params)

        window.randSeed = seed
        @map = new Map('map', params)
        @zoom()
        @map.draw()

        @canvas = document.getElementById('items')
        @canvas.onclick = @canvasClicked
        @canvas.width = @map.canvas.width
        @canvas.height = @map.canvas.height
        @ctx = @canvas.getContext('2d')
        @items = {
            start: [50,50]
            exit: [60,20]
            monsters: []
            triggers: []
            orbs: []}


    canvasClicked: (e) ->
        tileSize = Dungeon.map.tileSize
        Dungeon.addItem Math.floor(e.layerX / tileSize), Math.floor(e.layerY / tileSize)
        Dungeon.drawItems()

    randomSeed: ->
        byId('seed').value = Math.floor(Math.random() * 1000000)

    zoom: ->
        # @map.canvas.style.transform = "scale(#{byId('zoom').value})"
        @map.canvas.style.width = @map.canvas.width * parseFloat(byId('zoom').value)+'px'

    drawItems: ->
        @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
        tileSize = @map.tileSize
        @ctx.fillStyle = 'rgba(100,100,255,0.5)'
        for item in @items.triggers
            offset = (item.r - 1) / 2
            @ctx.fillRect((item.x - offset) * tileSize, (item.y - offset) * tileSize, tileSize * item.r, tileSize * item.r)
            @ctx.strokeStyle = 'rgba(100,100,255,1.0)'
            @ctx.strokeRect(item.x * tileSize - 1, item.y * tileSize - 1, tileSize + 2, tileSize + 2)
        @ctx.fillStyle = 'cyan'
        for item in @items.orbs
            @ctx.fillRect(item[0] * tileSize, item[1] * tileSize, tileSize, tileSize)
        @ctx.fillStyle = 'red'
        for item in @items.monsters
            @ctx.fillRect(item[0] * tileSize, item[1] * tileSize, tileSize, tileSize)
        @ctx.fillStyle = 'limegreen'
        item = @items.start
        @ctx.fillRect(item[0] * tileSize, item[1] * tileSize, tileSize, tileSize)
        @ctx.fillStyle = 'green'
        item = @items.exit
        @ctx.fillRect(item[0] * tileSize, item[1] * tileSize, tileSize, tileSize)

    addItem: (x, y) ->
        itemType = byId('item-type').value
        if itemType == 'start' || itemType == 'exit'
            @items[itemType] = [x,y]
        else if itemType == 'triggers'
            match = -1
            for item, i in @items[itemType]
                console.log 'checking:', item
                if item.x == x && item.y == y
                    console.log 'match:', i
                    match = i
            if match >= 0
                console.log 'removing trigger', @items[itemType][match]
                @items[itemType].splice(match, 1)
            else
                item = {x: x, y: y}
                item.r = byId('trigger-range').value
                name = byId('trigger-name').value
                if name.length > 0
                    item.name = name
                msg = byId('trigger-msg').value
                if msg.length > 0
                    item.msg = msg
                else
                    item.action = 'game.onTrigger(t)'
                console.log 'adding trigger', item
                @items[itemType].push item
        else
            match = -1
            for item, i in @items[itemType]
                if item[0] == x && item[1] == y
                    match = i
            if match >= 0
                @items[itemType].splice(match, 1)
            else
                @items[itemType].push [x,y]
        byId('locations').value = JSON.stringify(@items)

    updateItemList: ->
        json = byId('locations').value
        if json.length > 10
            @items = JSON.parse(json)
            console.log(@items)
            @items.start ||= [50,50]
            @items.exit ||= [60,20]
            @items.monsters ||= []
            @items.triggers ||= []
            @items.orbs ||= []
            @drawItems()




window.pixels = 1
