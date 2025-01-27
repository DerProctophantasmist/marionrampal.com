if !Array.isArray 
  Array.isArray = (arg) ->
    Object.prototype.toString.call(arg) == '[object Array]'

hyphensToCamelCase = (str)->
    arr = str.split(/[_-]/)
    newStr = arr.shift()
    for split in arr
        newStr += split.charAt(0).toUpperCase() + split.slice(1)
    return newStr

module.exports = {
  hyphensToCamelCase
}