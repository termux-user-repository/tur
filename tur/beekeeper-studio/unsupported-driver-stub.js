// Placeholder for a native driver that has no Android build.
// Loading succeeds so the app can start, using the driver throws.
const message = "@NAME@ is not supported on Termux";

const handler = {
	get(_target, key) {
		if (key === Symbol.hasInstance) return () => false;
		if (key === Symbol.toPrimitive) return () => "unsupported";
		if (typeof key === "symbol" || key === "__esModule" || key === "then") return undefined;
		return new Proxy(function () {}, handler);
	},
	apply() {
		throw new Error(message);
	},
	construct() {
		throw new Error(message);
	},
};

module.exports = new Proxy(function () {}, handler);
