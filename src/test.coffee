#!/usr/bin/env coffee
log = console.log.bind console
tap = require '@sa0001/wrap-tap'

prettyPrint = require './index'

##======================================================================================================================

tap.test 'pretty-print', (t) ->
	
	class Model
	getArgs = -> arguments
	basicValues =
		arg: getArgs true, 123, 'abc', { a: 1, b: 2, c: 3 }
		arr1: [ 1, 2, 3 ]
		arr2: Array(1,2,3)
		arr3: new Array(1,2,3)
		boo1: true
		boo2: false
		boo3: Boolean(true)
		boo4: new Boolean(true)
		dat: new Date(981173106789) # must have new
		err1: Error()
		err2: new Error('abc')
		err3: ReferenceError()
		err4: new ReferenceError('abc')
		err5: TypeError()
		err6: new TypeError('abc')
		fun1: ->
		fun2: `() => {}`
		fun3: Function('a', 'b', 'return a + b')
		fun4: new Function('a', 'b', 'return a + b')
		map: do ->
			v = new Map()
			v.set { key: 'val' }, 'obj'
			return v
		nul: null
		num1: 1.23
		num2: Number(1.23)
		num3: new Number(1.23)
		num4: (1 / 'A') # NaN
		num5: (1 / 0  ) # Infinity
		obj1: { a: 1, b: 2, c: 3 }
		obj2: Object({ a: 1, b: 2, c: 3 })
		obj3: new Object({ a: 1, b: 2, c: 3 })
		obj4: new Model()
		pro: new Promise -> # must have new
		reg1: /[\d]/
		reg2: RegExp '[\\d]'
		reg3: new RegExp '[\\d]'
		set: new Set([1,2,3]) # must have new
		str1: 'abc'
		str2: String('abc')
		str3: new String('abc')
		sym: Symbol('abc') # must NOT have new
		und: undefined
		wmap: do ->
			v = new WeakMap()
			v.set { key: 'val' }, 'obj'
			return v
	
	basicValuesOutput = """
		{
			arg: (function(){return arguments}).apply(null,[
				true,
				123,
				"abc",
				{ a: 1, b: 2, c: 3 }
			]),
			arr1: [ 1, 2, 3 ],
			arr2: [ 1, 2, 3 ],
			arr3: [ 1, 2, 3 ],
			boo1: true,
			boo2: false,
			boo3: true,
			boo4: true,
			dat: new Date(981173106789 /*2001-02-03T04:05:06.789Z*/),
			err1: new Error(),
			err2: new Error("abc"),
			err3: new ReferenceError(),
			err4: new ReferenceError("abc"),
			err5: new TypeError(),
			err6: new TypeError("abc"),
			fun1: '<<Function>>',
			fun2: '<<Function>>',
			fun3: '<<Function>>',
			fun4: '<<Function>>',
			map: (function(){
				let v = new Map()
				v.set({ key: "val" }, "obj")
				return v
			}()),
			nul: null,
			num1: 1.23,
			num2: 1.23,
			num3: 1.23,
			num4: NaN,
			num5: Infinity,
			obj1: { a: 1, b: 2, c: 3 },
			obj2: { a: 1, b: 2, c: 3 },
			obj3: { a: 1, b: 2, c: 3 },
			obj4: {},
			pro: new Promise(),
			reg1: /[\\d]/,
			reg2: /[\\d]/,
			reg3: /[\\d]/,
			set: new Set([ 1, 2, 3 ]),
			str1: "abc",
			str2: "abc",
			str3: "abc",
			sym: Symbol("abc"),
			und: undefined,
			wmap: new WeakMap(/*...*/)
		}
	"""
	
	values = ->
		a: undefined
		b: null
		c: true
		d: 123
		e: 'ABC'
	deepValues =
		a: b: c: d: values()
		b: [[[[ Object.keys(values) ]]]]
		c: [{
			d: [{
				e: values()
			}]
		}]
	
	functions_normal =
		empty: ->
		args_0: -> 'CONSTANT'
		args_1: (str) -> str.toLowerCase()
		args_2: (num1, num2) -> num1 + num2
		args_3: (a, b, c) -> [a, b, c].sort()
	functions_arrow =
		empty: `() => {}`
		args_0: `() => { return 'CONSTANT' }`
		args_1: `(str) => { return str.toLowerCase() }`
		args_2: `(num1, num2) => { return num1 + num2 }`
		args_3: `(a, b, c) => { return [a, b, c].sort() }`
	
	recursives =
		arr: [
			true
			1
			'A'
			[]
			{}
			->
		]
		obj:
			a: true
			b: 1
			c: 'A'
			d: []
			e: {}
			f: ->
	recursives.arr2 = recursives.arr
	recursives.arr3 = [ true, recursives.arr ]
	recursives.obj2 = recursives.obj
	recursives.obj3 = { a: true, b: recursives.obj }
	
	##--------------------------------------------------------------------------
	
	t.test 'basic + tabs', (t) ->
		output = prettyPrint basicValues
		
		t.eq output, basicValuesOutput
	
	t.test 'basic + spaces', (t) ->
		output = prettyPrint basicValues, { indentation: '  ' }
		
		t.eq output, basicValuesOutput.replace /\t/g, '  '
	
	t.test 'deep', (t) ->
		output = prettyPrint deepValues
		
		t.eq output, """
			{
				a: {
					b: {
						c: {
							d: { a: undefined, b: null, c: true, d: 123, e: "ABC" }
						}
					}
				},
				b: [
					[
						[
							[
								[]
							]
						]
					]
				],
				c: [
					{
						d: [
							{
								e: { a: undefined, b: null, c: true, d: 123, e: "ABC" }
							}
						]
					}
				]
			}
		"""
	
	t.test 'functions (normal)', (t) ->
		output = prettyPrint functions_normal, { functions: true }
		
		t.eq output, """
			{
				empty: function () {},
				args_0: function () {
					return 'CONSTANT';
				},
				args_1: function (str) {
					return str.toLowerCase();
				},
				args_2: function (num1, num2) {
					return num1 + num2;
				},
				args_3: function (a, b, c) {
					return [a, b, c].sort();
				}
			}
		"""
	
	t.test 'functions (arrow)', (t) ->
		output = prettyPrint functions_arrow, { functions: true }
		
		t.eq output, """
			{
				empty: () => {},
				args_0: () => { return 'CONSTANT' },
				args_1: (str) => { return str.toLowerCase() },
				args_2: (num1, num2) => { return num1 + num2 },
				args_3: (a, b, c) => { return [a, b, c].sort() }
			}
		"""
	
	t.test 'recursive objects', (t) ->
		output = prettyPrint recursives, { functions: true }
		
		t.eq output, """
			{
				arr: [
					true,
					1,
					"A",
					[],
					{},
					function () {}
				],
				obj: {
					a: true,
					b: 1,
					c: "A",
					d: [],
					e: {},
					f: function () {}
				},
				arr2: '<<Recursive>>',
				arr3: [ true, '<<Recursive>>' ],
				obj2: '<<Recursive>>',
				obj3: { a: true, b: '<<Recursive>>' }
			}
		"""
