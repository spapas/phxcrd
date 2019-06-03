(() => {
	'use strict'

	const $popoverLinks = document.querySelectorAll('[data-popover]')
	const $popovers = document.querySelectorAll('.popover')
	let i

	for (i = 0; i < $popoverLinks.length; i++) $popoverLinks[i].addEventListener('click', openPopover)

	document.addEventListener('click', closePopover)

	// Close Popover
	function closePopover(event) {
		for (i = 0; i < $popovers.length; i++) $popovers[i].classList.remove('popover-open')
	}

	// Open Popover
	function openPopover(event) {
		event.preventDefault()
		if (document.querySelector(this.getAttribute('href')).classList.contains('popover-open')) {
			document.querySelector(this.getAttribute('href')).classList.remove('popover-open')
		} else {
			closePopover()
			document.querySelector(this.getAttribute('href')).classList.add('popover-open')
		}
		event.stopImmediatePropagation()
	}

	if (typeof console == "object") {
		setTimeout(function () {
			console.log("%cWhy so curious?", "font:24px 'Calibri',sans-serif; color:#ac0408;");
		}, 1);
	}

///// Presense

function getMeta(metaName) {
	const metas = document.getElementsByTagName('meta');
  
	for (let i = 0; i < metas.length; i++) {
	  if (metas[i].getAttribute('name') === metaName) {
		return metas[i].getAttribute('content');
	  }
	}
  
	return '';
  }
  
  

let socket = new Phoenix.Socket("/socket", {
	params: {channel_token: getMeta('channel_token')}
})

let channel = socket.channel("room:lobby", {})
let presence = new Phoenix.Presence(channel)

function renderOnlineUsers(presence) {
  let response = ""

  presence.list((id, {metas: [first, ...rest]}) => {
	//console.log("ID = " + id +".", first, rest  )
    let count = rest.length + 1
    response += `<br>${id} ${first.username} ${first.authority_name} (count: ${count})</br>`
  })

  console.log(response)
  //document.querySelector("main[role=main]").innerHTML = response
}

socket.connect()
presence.onSync(() => renderOnlineUsers(presence))
channel.join()

})()