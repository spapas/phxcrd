(() => {
	'use strict'

	const $popoverLinks = document.querySelectorAll('[data-popover]')
	const $popovers = document.querySelectorAll('.popover')
	let i

	for (i = 0; i < $popoverLinks.length; i++) $popoverLinks[i].addEventListener('click', openPopover)

	document.addEventListener('click', closePopover)

	// Close Popover
	function closePopover (event) {
		for (i = 0; i < $popovers.length; i++) $popovers[i].classList.remove('popover-open')
	}

	// Open Popover
	function openPopover (event) {
		event.preventDefault()
		if (document.querySelector(this.getAttribute('href')).classList.contains('popover-open')) {
			document.querySelector(this.getAttribute('href')).classList.remove('popover-open')
		} else {
			closePopover()
			document.querySelector(this.getAttribute('href')).classList.add('popover-open')
		}
		event.stopImmediatePropagation()
	}
})()