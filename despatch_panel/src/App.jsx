import {
	AlertTriangle,
	CheckCircle,
	Clock,
	Eye,
	Filter,
	Map,
	MapPin,
	Navigation,
	Phone,
	Search,
	User,
	XCircle,
} from 'lucide-react'
import { useEffect, useState } from 'react'

const EmergencyDispatchPanel = () => {
	const [currentUser, setCurrentUser] = useState(null)
	const [activeView, setActiveView] = useState('login')
	const [selectedEmergency, setSelectedEmergency] = useState(null)
	const [statusFilter, setStatusFilter] = useState('all')
	const [searchTerm, setSearchTerm] = useState('')
	const [emergencies, setEmergencies] = useState([])
	const [responders, setResponders] = useState([])
	const [loading, setLoading] = useState(false)

	// BASE URL for API
	const API_BASE_URL = 'http://localhost:8000/api'

	// API Helper
	const apiCall = async (endpoint, options = {}) => {
		const token = localStorage.getItem('authToken')
		const defaultHeaders = {
			'Content-Type': 'application/json',
			...(token && { Authorization: `Bearer ${token}` }),
		}

		try {
			const response = await fetch(`${API_BASE_URL}${endpoint}`, {
				headers: { ...defaultHeaders, ...options.headers },
				...options,
			})

			if (!response.ok) {
				if (response.status === 401) {
					localStorage.removeItem('authToken')
					setCurrentUser(null)
					setActiveView('login')
				}
				throw new Error(`HTTP error! status: ${response.status}`)
			}

			return await response.json()
		} catch (error) {
			console.error('API call failed:', error)
			throw error
		}
	}

	// Load emergencies from Django API
	const loadEmergencies = async () => {
		try {
			setLoading(true)
			const data = await apiCall('/emergencies/')

			// Transform Django data to match our component structure
			const transformedData = data.map(item => ({
				...item,
				timestamp: new Date(item.timestamp),
				location:
					typeof item.location === 'string'
						? JSON.parse(item.location)
						: item.location,
			}))
			setEmergencies(transformedData)
		} catch (error) {
			console.error('Failed to load emergencies:', error)
		} finally {
			setLoading(false)
		}
	}

	// Load responders from Django API
	const loadResponders = async () => {
		try {
			const data = await apiCall('/responders/')
			setResponders(data.map(r => r.name || r.username))
		} catch (error) {
			console.error('Failed to load responders:', error)
			// Fallback to static data
			setResponders([
				'Fire Team Alpha',
				'Fire Team Beta',
				'Medical Unit 1',
				'Medical Unit 2',
				'Security Unit 1',
				'Security Unit 2',
				'Police Unit 1',
				'Police Unit 2',
			])
		}
	}

	// Load data when user logs in
	useEffect(() => {
		if (currentUser) {
			loadEmergencies()
			loadResponders()

			// Set up polling for real-time updates
			const interval = setInterval(loadEmergencies, 30000)
			return () => clearInterval(interval)
		}
	}, [currentUser])

	const handleLogin = async (username, password, role) => {
		// Static login for demo
		if (username === 'Bekhruz' && password === '1234') {
			setCurrentUser({
				username: 'Bekhruz',
				role: role,
				id: 1,
			})
			setActiveView('dashboard')
			return
		}

		try {
			setLoading(true)
			const response = await fetch(`${API_BASE_URL}/auth/login/`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({ username, password, role }),
			})

			if (response.ok) {
				const data = await response.json()
				localStorage.setItem('authToken', data.token)
				setCurrentUser({
					username: data.user.username,
					role: data.user.role,
					id: data.user.id,
				})
				setActiveView('dashboard')
			} else {
				const errorData = await response.json()
				alert(errorData.error || 'Login failed')
			}
		} catch (error) {
			console.error('Login error:', error)
			alert('Network error. Please try again.')
		} finally {
			setLoading(false)
		}
	}

	const handleAssign = async (emergencyId, responder) => {
		try {
			await apiCall(`/emergencies/${emergencyId}/assign/`, {
				method: 'POST',
				body: JSON.stringify({ assigned_to: responder }),
			})

			// Update local state
			setEmergencies(prev =>
				prev.map(e =>
					e.id === emergencyId
						? { ...e, assignedTo: responder, status: 'in_progress' }
						: e
				)
			)
		} catch (error) {
			console.error('Failed to assign emergency:', error)
			alert('Failed to assign emergency. Please try again.')
		}
	}

	const handleStatusChange = async (emergencyId, newStatus) => {
		try {
			await apiCall(`/emergencies/${emergencyId}/`, {
				method: 'PATCH',
				body: JSON.stringify({ status: newStatus }),
			})

			// Update local state
			setEmergencies(prev =>
				prev.map(e => (e.id === emergencyId ? { ...e, status: newStatus } : e))
			)
		} catch (error) {
			console.error('Failed to update status:', error)
			alert('Failed to update status. Please try again.')
		}
	}

	const getSeverityColor = severity => {
		switch (severity) {
			case 'critical':
				return 'bg-red-600'
			case 'high':
				return 'bg-orange-500'
			case 'medium':
				return 'bg-yellow-500'
			default:
				return 'bg-blue-500'
		}
	}

	const getStatusColor = status => {
		switch (status) {
			case 'pending':
				return 'text-red-600 bg-red-50'
			case 'in_progress':
				return 'text-yellow-600 bg-yellow-50'
			case 'resolved':
				return 'text-green-600 bg-green-50'
			default:
				return 'text-gray-600 bg-gray-50'
		}
	}

	const filteredEmergencies = emergencies.filter(e => {
		const matchesStatus = statusFilter === 'all' || e.status === statusFilter
		const matchesSearch =
			searchTerm === '' ||
			e.userName.toLowerCase().includes(searchTerm.toLowerCase()) ||
			e.type.toLowerCase().includes(searchTerm.toLowerCase()) ||
			e.id.toLowerCase().includes(searchTerm.toLowerCase())
		return matchesStatus && matchesSearch
	})

	const formatTime = date => {
		const now = new Date()
		const diff = Math.floor((now - date) / 60000) // minutes
		if (diff < 1) return 'Just now'
		if (diff < 60) return `${diff}m ago`
		if (diff < 1440) return `${Math.floor(diff / 60)}h ago`
		return date.toLocaleDateString()
	}

	// Login Component
	const LoginForm = () => {
		const [username, setUsername] = useState('')
		const [password, setPassword] = useState('')
		const [role, setRole] = useState('dispatcher')

		return (
			<div className='min-h-screen bg-gray-900 flex items-center justify-center'>
				<div className='bg-white p-8 rounded-lg shadow-lg w-96'>
					<div className='text-center mb-6'>
						<AlertTriangle className='w-12 h-12 text-red-600 mx-auto mb-2' />
						<h1 className='text-2xl font-bold text-gray-900'>
							Emergency Dispatch
						</h1>
						<p className='text-gray-600'>Secure Access Portal</p>
					</div>

					<div>
						<div className='mb-4'>
							<label className='block text-sm font-medium text-gray-700 mb-2'>
								Username
							</label>
							<input
								type='text'
								value={username}
								onChange={e => setUsername(e.target.value)}
								className='w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500'
								placeholder='Enter username'
							/>
						</div>

						<div className='mb-4'>
							<label className='block text-sm font-medium text-gray-700 mb-2'>
								Password
							</label>
							<input
								type='password'
								value={password}
								onChange={e => setPassword(e.target.value)}
								className='w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500'
								placeholder='Enter password'
							/>
						</div>

						<div className='mb-6'>
							<label className='block text-sm font-medium text-gray-700 mb-2'>
								Role
							</label>
							<select
								value={role}
								onChange={e => setRole(e.target.value)}
								className='w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500'
							>
								<option value='dispatcher'>Dispatcher</option>
								<option value='responder'>Responder</option>
							</select>
						</div>

						<button
							onClick={() => handleLogin(username, password, role)}
							className='w-full bg-red-600 text-white py-2 px-4 rounded-md hover:bg-red-700 transition-colors'
						>
							Login
						</button>
					</div>
				</div>
			</div>
		)
	}

	// Dashboard Component
	const Dashboard = () => (
		<div className='min-h-screen bg-gray-50'>
			{/* Header */}
			<div className='bg-white shadow-sm border-b'>
				<div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8'>
					<div className='flex items-center justify-between h-16'>
						<div className='flex items-center'>
							<AlertTriangle className='w-8 h-8 text-red-600 mr-3' />
							<h1 className='text-xl font-semibold text-gray-900'>
								Emergency Dispatch Panel
							</h1>
						</div>
						<div className='flex items-center space-x-4'>
							<span className='text-sm text-gray-600'>
								Welcome, {currentUser?.username}
							</span>
							<button
								onClick={() => setActiveView('history')}
								className='text-sm text-gray-600 hover:text-gray-900'
							>
								History
							</button>
							<button
								onClick={() => {
									localStorage.removeItem('authToken')
									setCurrentUser(null)
									setActiveView('login')
								}}
								className='text-sm text-red-600 hover:text-red-800'
							>
								Logout
							</button>
						</div>
					</div>
				</div>
			</div>

			<div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6'>
				{/* Filters */}
				<div className='mb-6 flex flex-wrap gap-4 items-center'>
					<div className='flex items-center space-x-2'>
						<Filter className='w-4 h-4 text-gray-500' />
						<select
							value={statusFilter}
							onChange={e => setStatusFilter(e.target.value)}
							className='px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500'
						>
							<option value='all'>All Status</option>
							<option value='pending'>Pending</option>
							<option value='in_progress'>In Progress</option>
							<option value='resolved'>Resolved</option>
						</select>
					</div>

					<div className='flex items-center space-x-2'>
						<Search className='w-4 h-4 text-gray-500' />
						<input
							type='text'
							value={searchTerm}
							onChange={e => setSearchTerm(e.target.value)}
							placeholder='Search by name, type, or ID...'
							className='px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500 w-64'
						/>
					</div>
				</div>

				{/* Emergency List */}
				{loading ? (
					<div className='flex justify-center items-center py-8'>
						<div className='text-gray-500'>Loading emergencies...</div>
					</div>
				) : (
					<div className='grid gap-4'>
						{filteredEmergencies.length === 0 ? (
							<div className='bg-white rounded-lg shadow-sm border border-gray-200 p-8 text-center'>
								<p className='text-gray-500'>No emergencies found</p>
							</div>
						) : (
							filteredEmergencies.map(emergency => (
								<div
									key={emergency.id}
									className='bg-white rounded-lg shadow-sm border border-gray-200 p-4'
								>
									<div className='flex items-center justify-between'>
										<div className='flex items-center space-x-4'>
											<div
												className={`w-3 h-3 rounded-full ${getSeverityColor(
													emergency.severity
												)}`}
											></div>
											<div>
												<h3 className='font-semibold text-gray-900'>
													{emergency.type}
												</h3>
												<p className='text-sm text-gray-600'>
													ID: {emergency.id}
												</p>
											</div>
										</div>

										<div className='flex items-center space-x-4'>
											<div className='text-right'>
												<p className='font-medium text-gray-900'>
													{emergency.userName}
												</p>
												<p className='text-sm text-gray-600'>
													{formatTime(emergency.timestamp)}
												</p>
											</div>

											<div className='flex items-center space-x-2'>
												<MapPin className='w-4 h-4 text-gray-500' />
												<span className='text-sm text-gray-600'>
													{emergency.location.address}
												</span>
											</div>

											<span
												className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(
													emergency.status
												)}`}
											>
												{emergency.status.replace('_', ' ').toUpperCase()}
											</span>

											<button
												onClick={() => setSelectedEmergency(emergency)}
												className='p-2 text-gray-500 hover:text-gray-700'
											>
												<Eye className='w-4 h-4' />
											</button>
										</div>
									</div>

									{emergency.assignedTo && (
										<div className='mt-2 flex items-center text-sm text-gray-600'>
											<User className='w-4 h-4 mr-1' />
											Assigned to: {emergency.assignedTo}
										</div>
									)}
								</div>
							))
						)}
					</div>
				)}
			</div>
		</div>
	)

	// Emergency Details Modal
	const EmergencyDetails = ({ emergency, onClose }) => (
		<div className='fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50'>
			<div className='bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto'>
				<div className='p-6'>
					<div className='flex items-center justify-between mb-4'>
						<h2 className='text-xl font-semibold text-gray-900'>
							Emergency Details
						</h2>
						<button
							onClick={onClose}
							className='text-gray-500 hover:text-gray-700'
						>
							<XCircle className='w-6 h-6' />
						</button>
					</div>

					<div className='grid grid-cols-2 gap-4 mb-6'>
						<div>
							<label className='block text-sm font-medium text-gray-700 mb-1'>
								Emergency ID
							</label>
							<p className='text-sm text-gray-900'>{emergency.id}</p>
						</div>
						<div>
							<label className='block text-sm font-medium text-gray-700 mb-1'>
								Type
							</label>
							<p className='text-sm text-gray-900'>{emergency.type}</p>
						</div>
						<div>
							<label className='block text-sm font-medium text-gray-700 mb-1'>
								Severity
							</label>
							<div className='flex items-center'>
								<div
									className={`w-3 h-3 rounded-full ${getSeverityColor(
										emergency.severity
									)} mr-2`}
								></div>
								<span className='text-sm text-gray-900 capitalize'>
									{emergency.severity}
								</span>
							</div>
						</div>
						<div>
							<label className='block text-sm font-medium text-gray-700 mb-1'>
								Status
							</label>
							<span
								className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(
									emergency.status
								)}`}
							>
								{emergency.status.replace('_', ' ').toUpperCase()}
							</span>
						</div>
					</div>

					<div className='grid grid-cols-2 gap-4 mb-6'>
						<div>
							<label className='block text-sm font-medium text-gray-700 mb-1'>
								Contact Person
							</label>
							<p className='text-sm text-gray-900'>{emergency.userName}</p>
						</div>
						<div>
							<label className='block text-sm font-medium text-gray-700 mb-1'>
								Phone
							</label>
							<div className='flex items-center'>
								<Phone className='w-4 h-4 text-gray-500 mr-1' />
								<p className='text-sm text-gray-900'>{emergency.userPhone}</p>
							</div>
						</div>
					</div>

					<div className='mb-6'>
						<label className='block text-sm font-medium text-gray-700 mb-1'>
							Location
						</label>
						<div className='flex items-center justify-between'>
							<p className='text-sm text-gray-900'>
								{emergency.location.address}
							</p>
							<div className='flex space-x-2'>
								<button className='flex items-center px-3 py-1 bg-blue-100 text-blue-700 rounded-md text-sm hover:bg-blue-200'>
									<Map className='w-4 h-4 mr-1' />
									View Map
								</button>
								<button className='flex items-center px-3 py-1 bg-green-100 text-green-700 rounded-md text-sm hover:bg-green-200'>
									<Navigation className='w-4 h-4 mr-1' />
									Get Directions
								</button>
							</div>
						</div>
					</div>

					<div className='mb-6'>
						<label className='block text-sm font-medium text-gray-700 mb-1'>
							Description
						</label>
						<p className='text-sm text-gray-900 bg-gray-50 p-3 rounded-md'>
							{emergency.description}
						</p>
					</div>

					<div className='mb-6'>
						<label className='block text-sm font-medium text-gray-700 mb-1'>
							Timestamp
						</label>
						<div className='flex items-center'>
							<Clock className='w-4 h-4 text-gray-500 mr-1' />
							<p className='text-sm text-gray-900'>
								{emergency.timestamp.toLocaleString()}
							</p>
						</div>
					</div>

					{currentUser?.role === 'dispatcher' && (
						<div className='border-t pt-4'>
							<h3 className='font-medium text-gray-900 mb-3'>Actions</h3>
							<div className='flex flex-wrap gap-2'>
								{emergency.status === 'pending' && (
									<select
										onChange={e => {
											if (e.target.value) {
												handleAssign(emergency.id, e.target.value)
											}
										}}
										className='px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500'
										defaultValue=''
									>
										<option value=''>Assign to...</option>
										{responders.map(responder => (
											<option key={responder} value={responder}>
												{responder}
											</option>
										))}
									</select>
								)}

								{emergency.status !== 'resolved' && (
									<button
										onClick={() => handleStatusChange(emergency.id, 'resolved')}
										className='flex items-center px-3 py-2 bg-green-600 text-white rounded-md hover:bg-green-700'
									>
										<CheckCircle className='w-4 h-4 mr-1' />
										Mark Resolved
									</button>
								)}
							</div>
						</div>
					)}
				</div>
			</div>
		</div>
	)

	// History View
	const History = () => (
		<div className='min-h-screen bg-gray-50'>
			<div className='bg-white shadow-sm border-b'>
				<div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8'>
					<div className='flex items-center justify-between h-16'>
						<div className='flex items-center'>
							<button
								onClick={() => setActiveView('dashboard')}
								className='text-gray-600 hover:text-gray-900 mr-4'
							>
								← Back to Dashboard
							</button>
							<h1 className='text-xl font-semibold text-gray-900'>
								Emergency History
							</h1>
						</div>
					</div>
				</div>
			</div>

			<div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6'>
				<div className='bg-white rounded-lg shadow-sm'>
					<div className='p-6'>
						<table className='w-full'>
							<thead>
								<tr className='border-b'>
									<th className='text-left py-3 text-sm font-medium text-gray-700'>
										ID
									</th>
									<th className='text-left py-3 text-sm font-medium text-gray-700'>
										Type
									</th>
									<th className='text-left py-3 text-sm font-medium text-gray-700'>
										Contact
									</th>
									<th className='text-left py-3 text-sm font-medium text-gray-700'>
										Status
									</th>
									<th className='text-left py-3 text-sm font-medium text-gray-700'>
										Date
									</th>
									<th className='text-left py-3 text-sm font-medium text-gray-700'>
										Assigned To
									</th>
								</tr>
							</thead>
							<tbody>
								{emergencies.map(emergency => (
									<tr key={emergency.id} className='border-b hover:bg-gray-50'>
										<td className='py-3 text-sm text-gray-900'>
											{emergency.id}
										</td>
										<td className='py-3 text-sm text-gray-900'>
											{emergency.type}
										</td>
										<td className='py-3 text-sm text-gray-900'>
											{emergency.userName}
										</td>
										<td className='py-3'>
											<span
												className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(
													emergency.status
												)}`}
											>
												{emergency.status.replace('_', ' ').toUpperCase()}
											</span>
										</td>
										<td className='py-3 text-sm text-gray-900'>
											{emergency.timestamp.toLocaleDateString()}
										</td>
										<td className='py-3 text-sm text-gray-900'>
											{emergency.assignedTo || 'Unassigned'}
										</td>
									</tr>
								))}
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	)

	// Main render
	if (activeView === 'login') {
		return <LoginForm />
	}

	if (activeView === 'history') {
		return <History />
	}

	return (
		<>
			<Dashboard />
			{selectedEmergency && (
				<EmergencyDetails
					emergency={selectedEmergency}
					onClose={() => setSelectedEmergency(null)}
				/>
			)}
		</>
	)
}

export default EmergencyDispatchPanel
