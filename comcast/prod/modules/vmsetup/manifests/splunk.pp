class vmsetup::splunk {

    package {'rsync' :
	ensure	=> installed,
    }

    ssh_authorized_key { 'root@osstooloff.cable.comcast.com' :
	ensure	=> present,
	user	=> 'root',
	type	=> 'ssh-rsa',
	key	=> 'AAAAB3NzaC1yc2EAAAABIwAAAgEAwJc2nRMgd0Xmb5HWniOu7cuZTQ415iZZoAu1fFo0U0yg3RMkrS2kTwGtWob+NJeF+3TGE/YdGHzlEm/B+mevnhHAsUhfss3RZQ25so6ZoiinBTI+TIBLaoegAKSVPPJTOKoHFrhTmv6s6/m3JTX/OhCQsRvRwaBtf1ZnKiO2F5/ZTahMMqnKKhulXn/pDwDKOQw4NzdY6x77PObdZsfUbRx1Ht0xasoqI4vDCCg36kXJU58Qrdl4sfyOPzZLK9dHrI9yIgS/seA7SpnmoZPilGuHye/lkOR5GtGnb4/ICUmuMNh7O4WeDbkXp1Kt4VhBlYX6nJCUdaPsuFOnjCb+0Pd2MDpMc6JEL+3LlG6EhN9GhnGq857o9EreIus9JYpNE3dCOKlFYZUNzVDeTwnXxYMBoCSjYD0prF+x40r1qBkHkng6/x3Ky3fu5V/1LAotfe/PqWLGMGWCS2ZqTB/ichUi6wtFVbxQyKHon5uqJuWtUwY6RjsGTPmRRUfeJ9nxPs4DfeZmFZtJLIeQ77N2gw6r4gX8dxLAFfBFd+yMhNeKVdWtVK0sGPhhi8eyMfncrs5jOfNaR9Sj4iGxl3XwGsI2ZP7ctJblAHgeaxJFqLUFpl4d3aUFF0C5+dHSStXqRvbfxJfmeV0gpenO0ZxE+7EjXoLg5jpmGNKLKeaZKYE=',
    }

}
