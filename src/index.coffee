_ =
	assign: require 'lodash/assign'
	defaults: require 'lodash/defaults'
	isNil: require 'lodash/isNil'
	startsWith: require 'lodash/startsWith'
_.typeOf = require '@sa0001/type-of'

##======================================================================================================================

# function stringifcation
fnArgsRegex = /function[\s]?\(([^\)]+)?\)/
fnBodyBegRegex = /^function[\s]?\(([^\)]+)?\)([\s\t\r\n]+)?\{([\s\t\r\n]+)?/
fnBodyEndRegex = /([\s\t\r\n]+)?\}$/

# string escaping
metaChars =
	'\b': '\\b'
	'\t': '\\t'
	'\n': '\\n'
	'\f': '\\f'
	'\r': '\\r'
	'"' : '\\"'
	'\\': '\\\\'
escapeChars = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g
escape = (string) ->
	escapeChars.lastIndex = 0
	if escapeChars.test string
		string = string.replace escapeChars, (a) ->
			c = metaChars[a]
			return (if typeof c == 'string' then c else '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4))
	return '"' + string + '"'

# recursive arrays/objects
seenListCheck = (seenList, v) ->
	if seenList.indexOf(v) >= 0
		return true
	else
		seenList.push v
		return false

# indentation
indentWith = '\t'

# type conversion
convertSetToArray = (set) ->
	arr = []
	set.forEach (v) -> arr.push v
	return arr
convertArgumentsToArray = (arg) ->
	return Array.prototype.slice.call arg, 0

##------------------------------------------------------------------------------

# convert the value to pretty-printed format
prettify = (value, opts = {}) ->
	type = _.typeOf value
	
	switch type
		when 'arguments'
			value = convertArgumentsToArray value
			value = prettify value, opts
			value = '(function(){return arguments}).apply(null,' + value.replace(/,$/,'') + ')'
			return value
		
		when 'boolean'
			return String value
		
		when 'date'
			return 'new Date('+value.getTime()+' /*'+value.toISOString()+'*/)'
		
		when 'error'
			if _.isNil(value.message) || value.message == ''
				return 'new '+value.constructor.name+'()'
			else
				return 'new '+value.constructor.name+'("'+value.message+'")'
		
		when 'map'
			# backup and add indent
			indentLast = opts.indent
			opts.indent += indentWith
			
			str = "(function(){\n#{opts.indent}let v = new Map()"
			
			iterator = value.keys()
			while (item = iterator.next()) && !item.done
				key = item.value
				val = value.get key
				str += "\n#{opts.indent}v.set(#{prettify(key, opts)}, #{prettify(val, opts)})"
			
			str += "\n#{opts.indent}return v\n#{indentLast}}())"
			
			# restore indent
			opts.indent = indentLast
			
			return str
		
		when 'null'
			return String value
		
		when 'number'
			# some special values
			return 'NaN'       if isNaN value
			return 'Infinity'  if value == Infinity
			return '-Infinity' if value == -Infinity
			return String value
		
		when 'promise'
			# not possible to represent the function
			return 'new Promise()'
		
		when 'regexp'
			return value.toString().replace /\/\//g, '\/'
		
		when 'set'
			value = convertSetToArray value
			value = prettify value, opts
			value = 'new Set(' + value + ')'
			return value
		
		when 'string'
			return escape value
		
		when 'symbol'
			value = value.toString()
			value = value.substring 7, value.length - 1
			value = escape value
			return 'Symbol(' + value + ')'
		
		when 'undefined'
			return String value
		
		when 'weakmap'
			return "new WeakMap(/*...*/)"
		
		##------------------------------------------------------------------------
		
		when 'function'
			if opts.functions != true
				return "'<<Function>>'"
			
			if seenListCheck opts.seenList, value
				return "'<<Recursive>>'"
			
			# backup and add indent
			indentLast = opts.indent
			opts.indent += indentWith
			
			fnStr = String(value).replace 'function(', 'function ('
			try
				if _.startsWith fnStr, 'function'
					# extract list of arguments
					fnArgs = fnStr.match(fnArgsRegex)[1] || ''
					fnBodyBeg = fnStr.match(fnBodyBegRegex)[0]
					fnBodyEnd = fnStr.match(fnBodyEndRegex)[0]
					fnBody = fnStr.substring(fnBodyBeg.length, fnStr.length - fnBodyEnd.length)
					
					if fnBody.length == 0
						fnDef = "function (#{fnArgs}) {}"
					else
						fnBody = fnBody.replace(/\n/g, '\n'+opts.indent)
						fnDef = "function (#{fnArgs}) {\n#{opts.indent}#{fnBody}\n#{indentLast}}"
				
				else
					# probably an arrow function
					fnDef = fnStr
			
			catch err
				console.error err
				fnDef = fnStr
			
			# restore indent
			opts.indent = indentLast
			
			return fnDef
		
		##------------------------------------------------------------------------
		
		when 'array'
			if seenListCheck opts.seenList, value
				return "'<<Recursive>>'"
			
			# backup and add indent
			indentLast = opts.indent
			opts.indent += indentWith
			
			# does the array contain any arrays or objects
			isComplex = false
			
			# gather pretty sub-values
			results = []
			for i in [0...value.length]
				results[i] = prettify value[i], opts
				isComplex = true if results[i].substring(0,1) in ['[', '{']
			
			# compile the results
			if results.length == 0
				v = '[]'
			else
				result = results.join ', '
				
				if isComplex || result.length > 80
					# show each value on its own line
					v = '[\n' + opts.indent + results.join(',\n' + opts.indent) + '\n' + indentLast + ']'
				else
					# show all values on the same line
					v = '[ ' + result + ' ]'
			
			# restore indent
			opts.indent = indentLast
			
			return v
		
		# all other types...
		else
			###
			[object Object]
			[object JSON]
			[object Math]
			###
			
			if seenListCheck opts.seenList, value
				return "'<<Recursive>>'"
			
			# backup and add indent
			indentLast = opts.indent
			opts.indent += indentWith
			
			# does the array contain any arrays or objects
			isComplex = false
			
			# gather pretty sub-values
			results = []
			regexChars = /['": -.]/
			regexStart = /^[0-9]/
			for own k of value
				v = prettify value[k], opts
				isComplex = true if v.substring(0,1) in ['[', '{']
				
				if regexChars.test(k) || regexStart.test(k) then k = escape k
				results.push k + ': ' + v
			
			# compile the results
			if results.length == 0
				v = '{}'
			else
				result = results.join ', '
				
				if isComplex || result.length > 80
					# show each value on its own line
					v = '{\n' + opts.indent + results.join(',\n' + opts.indent) + '\n' + indentLast + '}'
				else
					# show all values on the same line
					v = '{ ' + result + ' }'
			
			# restore indent
			opts.indent = indentLast
			
			return v

##------------------------------------------------------------------------------

module.exports = (value, opts = {}) ->
	
	_.defaults opts,
		# also stringify functions
		functions: false
		# indentation character
		indentation: '\t'
	
	_.assign opts,
		# current indentation level
		indent: ''
		# list of recursive arrays/objects
		seenList: []
	
	return prettify(value, opts)
		# collapse arrays of arrays
		.replace /\[\t*\[/g, '[['
		.replace /\]\t*\]/g, ']]'
		.replace /\],\t*\[/g, '],['
		# collapse arrays of objects
		.replace /\[\t*\{/g, '[{'
		.replace /\}\t*\]/g, '}]'
		.replace /\},\t*\{/g, '},{'
		# replace multiple commas
		.replace /,,/g, ','
		# replace final comma
		.replace /,$,/, ''
		# replace tab with specified indentation
		.replace /\t/g, opts.indentation
