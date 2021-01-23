# @sa0001/pretty-print

[NPM][https://www.npmjs.com/package/@sa0001/pretty-print]

A library which will print any Javascript value, no matter how large or how many recursive elements, in a format which\
 is both human-readable and also valid Javascript - the result can be copied and pasted, resulting in the same values\
 (obviously this does not preserve references, nor unusual value types such as `new Boolean()`).
 
## Install

```bash
npm install @sa0001/pretty-print
```

## Usage

```javascript
const prettyPrint = require('@sa0001/pretty-print')

console.log(prettyPrint({
	arg: (function(){ return arguments })(true, 123, 'abc', { a: 1, b: 2, c: 3 }),
	arr1: [ 1, 2, 3 ],
	arr2: Array(1,2,3),
	arr3: new Array(1,2,3),
	boo1: true,
	boo2: false,
	boo3: Boolean(true),
	boo4: new Boolean(true),
	dat: new Date(981173106789),
	err1: Error(),
	err2: new Error('abc'),
	err3: ReferenceError(),
	err4: new ReferenceError('abc'),
	err5: TypeError(),
	err6: new TypeError('abc'),
	fun1: function(){}
	fun2: Function('a', 'b', 'return a + b'),
	fun3: new Function('a', 'b', 'return a + b'),
	map: (function(){
		let v = new Map()
		v.set({ key: "val" }, "obj")
		return v
	}()),
	nul: null,
	num1: 1.23,
	num2: Number(1.23),
	num3: new Number(1.23),
	num4: (1 / 'A'), // NaN
	num5: (1 / 0), // Infinity
	obj1: { a: 1, b: 2, c: 3 },
	obj2: Object({ a: 1, b: 2, c: 3 }),
	obj3: new Object({ a: 1, b: 2, c: 3 }),
	obj4: new CustomClass(),
	pro: new Promise(()=>{}),
	reg1: /[\d]/,
	reg2: RegExp('[\\d]'),
	reg3: new RegExp('[\\d]'),
	set: new Set([1,2,3]),
	str1: 'abc',
	str2: String('abc'),
	str3: new String('abc'),
	sym: Symbol('abc'),
	und: undefined,
	wmap: new WeakMap()
})
/*
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
	dat: new Date(981173106789 /*2001-02-03T04:05:06.789Z*\/),
	err1: new Error(),
	err2: new Error("abc"),
	err3: new ReferenceError(),
	err4: new ReferenceError("abc"),
	err5: new TypeError(),
	err6: new TypeError("abc"),
	fun1: '<<Function>>',
	fun2: '<<Function>>',
	fun3: '<<Function>>',
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
	wmap: new WeakMap()
}
*/

// there is also an option to print function bodies:
console.log(prettyPrint({
	arrow_empty: () => {},
	normal_empty: function () {},
	
	args_0: () => {
		return 'CONSTANT'
	},
	args_1: (str) => {
		return str.toLowerCase()
	},
	args_2: (num1, num2) => {
		return num1 + num2
	},
	args_3: (a, b, c) => {
		return [a, b, c].sort()
	},
},{
	functions: true,
}))
/*
{
	arrow_empty: () => {},
	normal_empty: function () {},
	args_0: () => {
		return 'CONSTANT';
	},
	args_1: str => {
		return str.toLowerCase();
	},
	args_2: (num1, num2) => {
		return num1 + num2;
	},
	args_3: (a, b, c) => {
		return [a, b, c].sort();
	}
}
*/
```

## License

[MIT](http://vjpr.mit-license.org)
