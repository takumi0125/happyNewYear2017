# class CustomGeometry extends THREE.InstancedBufferGeometry
#   constructor: (baseGeometry, @numInstances)->
#     super()
#
#     instanceIndices = new THREE.InstancedBufferAttribute new Float32Array(@numInstances), 1, 1
#     @copy baseGeometry
#     for i in [0...@numInstances] then instanceIndices.setX i, i
#
#     @addAttribute 'instanceIndex', instanceIndices
#
#
#
#   addData: (name, data, itemSize)->
#     dataArr = new THREE.InstancedBufferAttribute new Float32Array(@numInstances * itemSize), itemSize, 1
#
#     if itemSize is 1
#       for i in [0...@numInstances]
#         dataArr.setX i, data[i]
#     else if itemSize is 2
#       for i in [0...@numInstances]
#         d = data[i]
#         dataArr.setXY i, d.x, d.y
#     else if itemSize is 3
#       for i in [0...@numInstances]
#         d = data[i]
#         dataArr.setXYZ i, d.x, d.y, d.z
#
#     @addAttribute name, dataArr
#
#     @computeVertexNormals()
#     return
#
#
#
#   getRandomValue: ->
#     return (Math.random() + Math.random() + Math.random() + Math.random() + Math.random()) / 5
#
# module.exports = CustomGeometry


class CustomGeometry extends THREE.BufferGeometry
  constructor: (baseGeometry, @numInstances)->
    super()

    vertices = []
    instanceIndices = []
    uvs = []
    indices = []

    numIndices = baseGeometry.index.array.length
    @numPositions = baseGeometry.attributes.position.array.length

    for i in [0...@numInstances]
      for j in [0...@numPositions / 3]
        vertices.push baseGeometry.attributes.position.array[j * 3 + 0]
        vertices.push baseGeometry.attributes.position.array[j * 3 + 1]
        vertices.push baseGeometry.attributes.position.array[j * 3 + 2]
        uvs.push baseGeometry.attributes.uv.array[j * 2 + 0]
        uvs.push baseGeometry.attributes.uv.array[j * 2 + 1]
        instanceIndices.push i

      for j in [0...numIndices]
        indices.push baseGeometry.index.array[j] + @numPositions / 3 * i

    # attributes
    @addAttribute 'position', new THREE.BufferAttribute(new Float32Array(vertices), 3)
    @addAttribute 'uv', new THREE.BufferAttribute(new Float32Array(uvs), 2)
    @addAttribute 'instanceIndex', new THREE.BufferAttribute(new Float32Array(instanceIndices), 1)


    @setIndex new THREE.BufferAttribute(new Uint16Array(indices), 1)

    @computeVertexNormals()


  addData: (name, data, itemSize)->
    dataArr = []

    if itemSize is 1
      for i in [0...@numInstances]
        for j in [0...@numPositions / 3]
          dataArr.push data[i]

    else if itemSize is 2
      for i in [0...@numInstances]
        d = data[i]
        for j in [0...@numPositions / 3]
          dataArr.push d.x
          dataArr.push d.y

    else if itemSize is 3
      for i in [0...@numInstances]
        d = data[i]
        for j in [0...@numPositions / 3]
          dataArr.push d.x
          dataArr.push d.y
          dataArr.push d.z

    @addAttribute name, new THREE.BufferAttribute(new Float32Array(dataArr), itemSize)

    @computeVertexNormals()
    return


  getRandomValue: ->
    return (Math.random() + Math.random() + Math.random() + Math.random() + Math.random()) / 5


module.exports = CustomGeometry
